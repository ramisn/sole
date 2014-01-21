Spree::Admin::OrdersController.class_eval do
  include Spree::BaseHelper
  include ActionView::Helpers::NumberHelper
  
  before_filter :check_authorization
  #before_filter :check_for_past_due_items
  before_filter :set_fullsize
  #layout "merchant"
    
  def index
    params[:search] ||= {}
    params[:search][:completed_at_is_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
    @show_only_completed = params[:search][:completed_at_is_not_null].present?
    params[:search][:meta_sort] ||= @show_only_completed ? 'completed_at.desc' : 'created_at.desc'

    @search = Spree::Order.metasearch(params[:search])

    if !params[:search][:created_at_greater_than].blank?
      params[:search][:created_at_greater_than] = Time.zone.parse(params[:search][:created_at_greater_than]).beginning_of_day rescue ""
    else
      params[:search][:created_at_greater_than] = DateTime.new(2011, 11, 5).beginning_of_day
    end

    if !params[:search][:created_at_less_than].blank?
      params[:search][:created_at_less_than] = Time.zone.parse(params[:search][:created_at_less_than]).end_of_day rescue ""
    end

    if @show_only_completed
      params[:search][:completed_at_greater_than] = params[:search].delete(:created_at_greater_than) if params[:search][:completed_at_greater_than].blank?
      params[:search][:completed_at_less_than] = params[:search].delete(:created_at_less_than) if params[:search][:completed_at_less_than].blank?
    end
    
    @metasearch = Spree::Order.metasearch(params[:search])
    
    respond_to do |format|
      format.html do
        @orders = @metasearch.includes(:user, :shipments, :payments).
                  page(params[:page]).
                  per(Spree::Config[:orders_per_page])
        
        @all_orders = @metasearch.all
        @total_orders = @metasearch.count
        @total_items = @all_orders.map(&:total_quantity).sum
        @total_product_sales = @metasearch.sum(:item_total)
        @total_product_reimbursement = @all_orders.map(&:total_product_reimbursement).sum
        @total_tax = @all_orders.map(&:tax_total).sum
        @total_shipping = @all_orders.map(&:ship_total).sum
        @total_coupons = @all_orders.map(&:coupon_total).sum
        @total_sales = @all_orders.map(&:total).sum
        @total_commission = 0#@all_orders.map(&:soletron_commission).sum
        @all_orders.each do |order|
          @total_commission += order.soletron_commission if order.complete?
        end
        if @total_product_sales != 0
          @total_commission_percent = (@total_commission / (@total_product_sales + @total_coupons) * 100).round(1)
        end
        respond_with(@orders)
      end
      format.csv do
        @orders = @metasearch
        csv_data = CSV.generate do |csv|
          csv << [
            t('order_completed_at'), 
            t('order_number'), 
            t('shipping_to'), 
            t('coupon_codes'), 
            t('num_merchants'),
            t('num_items'),
            t('product_sales'), 
            t('coupon_discount'), 
            t('product_reimbursement'),
            t('shipping'), 
            t('tax'), 
            t('total'),
            t('commission_$'),
            t('commission_%'),
            t('checkout_stage'),
            t('payment_state'),
            t('shipment_state'),
            t('customer'),
          ]
          @orders.each do |order|
            csv << [
              (order.completed_at ? order.completed_at : order.created_at).strftime("%-m/%-d/%Y"),
              order.number,
              (order.ship_address ? order.ship_address.state : ''),
              (order.promotion_credits.count > 0 ? order.promotion_credits.collect {|pc| pc.source.code if pc.source }.join(", ") : ""),
              order.orders_stores.count,
              order.total_quantity,
              order.item_total,
              order.coupon_total,
              order.total_product_reimbursement,
              order.ship_total,
              order.tax_total,
              order.total,
              (order.complete? ? order.soletron_commission : ''),
              (begin "#{order.soletron_commission_rate.round(1)}" if order.complete? rescue '-' end),
              t("order_state.#{order.state.downcase}"),
              (order.payment_state ? t("payment_states.#{order.payment_state}") : ''),
              (order.shipment_state ? t("shipment_states.#{order.shipment_state}") : ''),
              order.email,
            ]
          end
        end
        
        render :text => csv_data, :layout => nil
      end
    end
  end
  
  def edit
    redirect_to admin_order_path(@order)
  end
  
  def confirm_force_cancel
    #puts "order found!"
    @jquery_16 = true
    #@order = Spree::Order.find_by_number!(params[:id])
  end
  
  def force_cancel
    #puts "order found!"
    #@order = Spree::Order.find_by_number!(params[:id])
    @order.force_cancel!
    if @order.canceled?
      OrderMailer.cancel_email(@order).deliver
      flash[:success] = "You have successfully forced the cancelation of the entire order."
    else
      flash[:error] = "The order was not canceled."
    end
    redirect_back_or_default admin_orders_path
  end
  
  def generate_pdf    
    @order = Spree::Order.find_by_number(params[:id])
    items = []
    unless @order.blank?
      @order.inventory_units.map do |inventory_unit|
        item = []
        
        if inventory_unit.backordered?
          item << "No"
        else
          item << "Yes"
        end
        
        sku = inventory_unit.variant ?  inventory_unit.variant.sku : nil
        item << sku
       
        if inventory_unit.variant and inventory_unit.variant.product
          title = inventory_unit.variant.product.name
        else
          title = ""
        end
        item << title
        
        unless inventory_unit.variant.nil? or inventory_unit.variant.option_values.empty?
          item << variant_options(inventory_unit.variant)
        else
          item << ""
        end
        
        item << inventory_unit.state
        
        store = inventory_unit.variant ? inventory_unit.variant.product.store : nil        
        if store
          item <<  store.name_from_taxon
          item <<  store.customer_support
        end
#        Push whole array in 2-D array
        items << item
      end
      date = (!@order.completed_at.blank? ? @order.completed_at : @order.created_at).strftime("%m/%d/%Y %I:%M %p")
      number = @order.number
      pdf = Prawn::Document.generate("order.pdf") do        
        text "Thank you for ordering with Soletron.com! Your order details are below:", :size => 10, :style => :bold, :align => :center
        
        move_down 10
        text "Order: #{number}", :size => 10, :style => :bold
        text "Order Date: #{date}", :size => 10, :style => :bold  
        
        move_down 10
        table(items,:cell_style => {:padding => 2},:border_style => :grid,  
          :row_colors => ["FFFFFF", "DDDDDD"], 
          :headers => ["Included in shipment", "Sku ", "Item Title", "Description","Status", "Seller name", "Seller contact"]) do
          cells.borders = [:bottom, :top, :left, :right]
        end
        
        move_down 15
        text "Questions?", :size => 10, :style => :bold
        text "We are dedicated to providing you with the best customer service possible, so please let us know if you have feedback on your shopping experience. ", :size => 8
        text "Soletron has a no-refund policy, but if you received the wrong size or a damaged item, please contact the seller above, as Soletron does not warehouse or ship those items to you. ", :size => 8
        text "If you have purchased an item from the Soletron store (an item with the Soletron brand name on it), please contact Soletron customer service with questions: (305)-793-4430. ", :size => 8
        
        move_down 15
        text "Get gift ideas and discounts on your next purchase!", :size => 10, :style => :bold
        text "If you have not already, sign up for a Soletron account or follow us on Facebook to get access to members-only exclusive discounts and promos. We look forward to doing business with you again in the future!", :size => 8
        
        move_down 15
        text "Yours Truly,", :size => 8
        text "The Soletron team", :size => 8
      end
      
    
      send_file pdf.path,
        :content_type => "application/pdf",
        :filename => "order.pdf"
    end
  end
  
  private

  def check_authorization
    load_order
    session[:access_token] ||= params[:token]

    resource = @order || Order
    action = params[:action].to_sym

    authorize! action, resource, session[:access_token]
  rescue # trap authorization failure for merchant panel
    authorize! :manage, self.class
  end

  def check_for_past_due_items
    LineItem.not_shipped.not_canceled.each do |item|
      order = Spree::Order.find(item.order_id)
      item.update!(order)
    end
  end
end