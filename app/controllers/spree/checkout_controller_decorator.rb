Spree::CheckoutController.class_eval do
  before_filter :check_registration, :except => [:registration, :update_registration, :guest_confirmation, :checkout_confirmation]
  before_filter :current_user_does_not_need_to_register, :only => [:registration]
  before_filter :tag_checkout_process
  before_filter :calculate_coupons, :only => [:update]
  before_filter :set_body_id, :only => [:edit]

  before_filter :login_guest, only: [:update]
  before_filter :one_step_checkout_setup, only: [:update]  

#  before_filter :only_allow_admin
  
  def tag_checkout_process
	#Added by Brett to use for removing certain page elements during checkout process
    @checkout_process = true
  end
  
  
  def only_allow_admin
	
	if current_user.nil?
		redirect_to '/disabled/checkout'	
	elsif !current_user.admin?
		redirect_to '/disabled/checkout'
	end
	
  end

  # Introduces a registration step whenever the +registration_step+ preference is true.
  def check_registration
    # return unless Spree::Auth::Config[:registration_step]
    # return if current_user
    # if !params[:confirmation_token].blank? and params[:confirmation_token] == current_order.user.confirmation_token
    #    current_order.user.confirm!
    #    flash[:notice] = 'Your email has been validated.'
    # end
    # # allow guest to move to cart for 20 minutes
    # return if !current_order.user.blank? and current_order.user.confirmed_at and current_order.user.confirmed_at > DateTime.now - 20.minutes and !current_order.email.nil?
    # store_location
    # redirect_to spree.checkout_registration_path
  end
  
  def current_user_does_not_need_to_register
    return unless current_user and current_order.user == current_user
    redirect_to spree.checkout_path
  end

  def paypal_finish
    load_order

    opts = { :token => params[:token], :payer_id => params[:PayerID] }.merge all_opts(@order, params[:payment_method_id], 'payment' )
    gateway = paypal_gateway

    if Spree::Config[:auto_capture]
      ppx_auth_response = gateway.purchase((@order.total*100).to_i, opts)
    else
      ppx_auth_response = gateway.authorize((@order.total*100).to_i, opts)
    end

    paypal_account = PaypalAccount.find_by_payer_id(params[:PayerID])

    payment = @order.payments.create(
      :amount => ppx_auth_response.params["gross_amount"].to_f,
      :source => paypal_account,
      :source_type => 'PaypalAccount',
      :payment_method_id => params[:payment_method_id],
      :response_code => ppx_auth_response.params["ack"],
      :avs_response => ppx_auth_response.avs_result["code"])

    payment.started_processing!

    record_log payment, ppx_auth_response

    if ppx_auth_response.success?
      #confirm status
      case ppx_auth_response.params["payment_status"]
      when "Completed"
        payment.complete!
      when "Pending"
        payment.pend!
      else
        payment.pend!
        Rails.logger.error "Unexpected response from PayPal Express"
        Rails.logger.error ppx_auth_response.to_yaml
      end

      #@order.update_totals
      #need to force checkout to complete state
      until @order.state == "complete"
        puts "**** order contents: #{@order.inspect}"
#        paypal_params = { "coupon_code" => "", "payment_attributes" => [{"payment_method_id" => params["payment_method_id"], "source_attributes" => {}, "amount" => @order.total}], "accepted_terms" => 1 }
#        if @order.update_attributes(paypal_params)
#          @order.next!
        if @order.next!
          @order.update!
          state_callback(:after)
        end
      end

      flash[:notice] = I18n.t(:order_processed_successfully)
      redirect_to completion_route

    else
      payment.fail!
      order_params = {}
      gateway_error(ppx_auth_response)

      #Failed trying to complete pending payment!
      redirect_to edit_order_checkout_url(@order, :state => "payment")
    end
  rescue ActiveMerchant::ConnectionError => e
    gateway_error I18n.t(:unable_to_connect_to_gateway)
    redirect_to edit_order_url(@order)
  end
  
  def before_address
    @order.bill_address ||= Spree::Address.default
    @order.ship_address ||= Spree::Address.default
    if object_params and !object_params[:use_bill_address].blank?
      @order.bill_address.update_attributes(object_params[:bill_address_attributes])
      @order.clone_billing_address 
    end
  end

  
  def before_delivery
  

    # creation and assignment of shipping method and instructions moved from order controller...
    if params[:order].present?
      params.each do |key, value|
        # cannot predict in what order params are delivered
        if key.include? 'instructions_'
          store_id = key.delete('instructions_').to_i
          shipment = @order.shipments.by_store(store_id).not_shipped.first
          if shipment.blank?
            SSpree::hipment.create(:order => @order,
                            :address => @order.ship_address,
                            :store_id => store_id,
                            :state => 'pending',
                            :instructions => value)
          else
            Spree::Shipment.update(shipment.id, :instructions => value)
          end
        end
        if key.include? 'store_'
          store_id = key.delete('store_').to_i
          shipment = @order.shipments.by_store(store_id).not_shipped.first
          if shipment.blank?
            Spree::Shipment.create(:order => @order,
                            :shipping_method_id => value,
                            :address => @order.ship_address,
                            :store_id => store_id,
                            :state => 'pending')
          else
            Spree::Shipment.update(shipment.id, :shipping_method_id => value)
          end
        end
      end
    else
      @order.shipping_method ||= (@order.rate_hash.first && @order.rate_hash.first[:shipping_method])
    end
  end
  
  # Overrides the default guest registration 
  def update_registration
    if params[:order][:email].strip.blank?
      flash[:error] = 'Error: You are required to input an email address.'
      render 'registration'
    elsif params[:order][:email] == params[:email_confirmation]
      current_order.state = "cart"

      if user = Spree::User.find_by_email(params[:order][:email])
        flash[:error] = "There is already an existing account on Soletron for that email address, please log in to your account before proceeding to checkout"
        render 'registration'
      else
        current_order.email = params[:order][:email]
        current_order.user = Spree::User.anonymous!

        if current_order.save(:validate => false)
          redirect_to checkout_path
        else
          flash[:error] = 'Error: Failed to save email in Order. Please make sure you had provided a valid email address.'
          render 'registration'
        end
      end
    else
      flash[:error] = 'Error: The two email addresses you entered do not match!'
      render 'registration'
    end
  end
  
  def guest_confirmation; end
  
  protected

  def login_guest
    user_params = params[:existing_user] || {}
    return if user_params[:login].blank? && user_params[:password].blank?

    user = User.find_by_username(user_params[:login]) || User.find_by_email(user_params[:login])
    if user && user.valid_password?(user_params[:password])
      sign_in :user, user
      @acting_as = current_user
    else
      # We do this on the instance so that future calls to #valid? return this error.
      # In this case we don't want the order to complete as a "guest" if the user thinks they have an account
      # with Soletron.
      def @order.valid?(*args)
        super
        errors.add :base, "Invalid username, email, or password."
        false
      end

    end    
  end

  def one_step_checkout_setup
    # Honor "billing_same_as_shipping" toggle on UI.
    if params[:billing_same_as_shipping] == "true"
      object_params[:bill_address_attributes].merge!(object_params[:ship_address_attributes])
    end

    # Copy over "phone" and "email" from shipping address to billing address
    if object_params
      email_phone = (object_params[:ship_address_attributes] || {}).slice(:email, :phone)
      object_params[:bill_address_attributes].merge!(email_phone)
    end

    # Reassemble CC# from its 4 constituent parts (its broken into 4 fields in the UI)
    if payment_hash = object_params && object_params[:payment_method]
      payment_hash["cc"] = (1..4).map { |i| payment_hash.delete("cc_#{i}") }.join
    end
  end
  
  def calculate_coupons
    if object_params and object_params[:coupon_code]
      @order.coupon_code = object_params[:coupon_code]
      @order.save
      @order.update!
    end
    
    # 3.1Break
    # check for all promotions that are automatic
    # Spree::Promotion::Rules::Automatic.all.each do |rule|
    #   rule.promotion.create_discount(current_order)
    # end
    @order.save
    @order.update!
  end
  
  def set_body_id
    @body_id = 'checkout'
  end

end
