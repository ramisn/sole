class Admin::VendorPaymentsController < Spree::Admin::ResourceController
  
  before_filter :load_vendor_payment_period, :only => [:new, :create]
  before_filter :require_can_pay, :only => [:new, :create]
  before_filter :require_no_outstanding_payments, :only => [:new, :create]
  before_filter :set_fullsize
  
  def index
    per = Spree::Config[:orders_per_page];
    
    @vendor_payments = VendorPayment.includes({:vendor_payment_period => :store}).page(params[:page]).per(per)
  end
  
  def reversed
    @vendor_payments = VendorPayment.reversed.paginate(:include => {:vendor_payment_period => :store},
                                              :per_page => Spree::Config[:orders_per_page],
                                              :page     => params[:page])
  end
  
  #def show
  #  @vendor_payment.find(params[:id])
  #  #if @vendor_payment.amount >= 0
  #  #  flash[:notice] = "That view is only availabled for reversed payments"
  #  #  redirect_to merchant_store_vendor_payment_period_path(@vendor_payment.vendor_payment_period.store, @vendor_payment.vendor_payment_period)
  #  #end
  #end
  
  def new
    @vendor_payment = @vendor_payment_period.vendor_payments.build(:admin => current_user)
    @vendor_payment.amount = @vendor_payment_period.to_pay
    
    current_product_reimbursement = @vendor_payment_period.orders_stores.sum(:product_reimbursement)
    current_coupons = @vendor_payment_period.orders_stores.sum(:coupons)
    current_shipping = @vendor_payment_period.orders_stores.sum(:shipping)
    
    if @vendor_payment.amount < 0 # a chargeback
      last_reversed_payment = @vendor_payment_period.vendor_payments.reversed.order('payments.created_at DESC').limit(1).first
      inventory_units = if last_reversed_payment
        last_inventory_unit = last_reversed_payment.inventory_units.order('inventory_units.canceled_at DESC').limit(1).first
        @vendor_payment_period.inventory_units.where('inventory_units.canceled_at > ?', last_inventory_unit.canceled_at)
      else
        paid_payment = @vendor_payment_period.vendor_payments.where('payments.amount > 0').order('payments.created_at ASC').limit(1).first
        @vendor_payment_period.inventory_units.where('inventory_units.canceled_at > ?', paid_payment.created_at)
      end
      @vendor_payment.product_sales = current_product_reimbursement - @vendor_payment_period.vendor_payments.sum(:product_sales)
      @vendor_payment.coupons = current_coupons - @vendor_payment_period.vendor_payments.sum(:coupons)
      @vendor_payment.shipping = current_shipping - @vendor_payment_period.vendor_payments.sum(:shipping)
      @vendor_payment.inventory_units = inventory_units
    else
      @vendor_payment.product_sales = current_product_reimbursement
      @vendor_payment.coupons = current_coupons
      @vendor_payment.shipping = current_shipping
    end
  end
  
  def create
    vendor_payment_params = params[:vendor_payment].dup
    vendor_payment_params[:admin_id] = current_user.id
    #vendor_payment_params[:inventory_units] = @vendor_payment_period.inventory_units.where(:id => params[:inventory_units])
    @vendor_payment = @vendor_payment_period.vendor_payments.create(vendor_payment_params)
    #@vendor_payment.inventory_units.reload
    if @vendor_payment.errors.empty?
      if @vendor_payment.amount > 0
        @vendor_payment.pay!
        if @vendor_payment.errors.empty?
          flash[:success] = "#{@vendor_payment_period.store.display_name}'s payment has been sent"
        else
          flash[:error] = "There was an error with the payment. #{@vendor_payment.errors}"
        end
      else
        @vendor_payment_period.inventory_units.where(:id => params[:inventory_units]).update_all(:vendor_payment_reversal_id => @vendor_payment)
        @vendor_payment.update_attribute_without_callbacks :state, 'pending'
        @vendor_payment.vendor_payment_period.update_payment_total!
        @vendor_payment.vendor_payment_period.update_state!
        flash[:success] = "The chargeback has been successfully added"
      end
      redirect_to admin_vendor_payment_periods_path
    else
      flash[:error] = "There were errors when trying to create the payment"
      render :new
    end
  end
  
  protected
  
  def load_vendor_payment_period
    unless @vendor_payment_period = VendorPaymentPeriod.find(params[:vendor_payment_period_id])
      flash[:error] = "Vendor Payment Period not found"
      redirect_to admin_vendor_payment_periods
    end
  end
  
  def require_can_pay
    unless !@vendor_payment_period.inactive? and !@vendor_payment_period.paid?
      flash[:error] = "You cannot make a payment to the store right now."
      redirect_to merchant_store_vendor_payment_period_path(@vendor_payment_period.store, @vendor_payment_period)
    end
    unless !@vendor_payment_period.store.usa_epay_customer_number.blank?
      flash[:error] = "You need to assign the store #{@vendor_payment_period.store.taxon.name}'s USA ePay customer number before you can make a payment"
      redirect_to admin_vendor_payment_periods_path
    end
  end
  
  def require_no_outstanding_payments
    unless @vendor_payment_period.vendor_payments.outstanding.count == 0
      flash[:notice] = "There are outstanding payments, so you cannot start another payment or chargeback a payment yet."
      redirect_to merchant_store_vendor_payment_period_path(@vendor_payment_period.store, @vendor_payment_period)
    end
  end

  protected
  def model_class
    VendorPayment
  end
end

  
