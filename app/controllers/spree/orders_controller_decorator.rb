Spree::OrdersController.class_eval do
  include Spree::BaseHelper
  before_filter :check_authorization, :except => [:checkout_confirmation]
  # before_filter :estimate_adjustments, :only => [:edit]
  before_filter :update_order_prices, :only => [:edit]
  before_filter :set_body_id, :only => [:new, :edit]
  
  def estimate_adjustments
    # estimate sales tax
    if current_order 
      current_order.adjustments.tax.each {|e| e.destroy }
      if current_order.ship_address.blank?
        current_order.ship_address = Spree::Address.default
      end
      if current_order.shipping_method.blank?
        current_order.shipping_method_id = Spree::Config[:default_shipping_method_id]
      end
      
      # 3.1Break
      # Spree Tax logic has drastically changed in 1.0.0. Line below breaks
      # Spree::TaxRate.match(current_order.ship_address).each {|r| r.create_adjustment(I18n.t(:tax), current_order, current_order, true) }
      
 
      # estimate shipping
      current_order.create_shipment!
      
      # check for all promotions that are automatic
      # 3.1Break
      # Spree::Promotion::Rules::Automatic.all.each do |rule|
      #   rule.promotion.create_discount(current_order)
      # end
     
      current_order.save(:validate => false)
      current_order.update!
    end
  end

  def checkout_confirmation
    if current_order and current_order.user.confirmation_token == params[:confirmation_token]
      if current_order.user.username.blank?
        current_order.user.generate_username
        current_order.user.update_attribute_without_callbacks 'username', current_order.user.username
      end
      current_order.user.confirm!
      flash[:notice] = 'Your email has been confirmed.'
      redirect_to checkout_path
    else
      flash[:error] = 'Error: Email Confirmation failed.'
      redirect_to main_app.root_path
    end
  end
  
  def remove_item
    Spree::LineItem.destroy(params[:id]) if current_order.line_items.find(params[:id])
    current_order.update!
    redirect_to cart_path
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
          item << variant_options(inventory_unit.variant).html_safe
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

  # Adds a new item to the order (creating a new order if none already exists)
  #
  # Parameters can be passed using the following possible parameter configurations:
  #
  # * Single variant/quantity pairing
  # +:variants => {variant_id => quantity}+
  #
  # * Multiple products at once
  # +:products => {product_id => variant_id, product_id => variant_id}, :quantity => quantity +
  # +:products => {product_id => variant_id, product_id => variant_id}}, :quantity => {variant_id => quantity, variant_id => quantity}+
  def populate
    @order = current_order(true)

    params[:products].each do |product_id,variant_id|
      quantity = params[:quantity].to_i if !params[:quantity].is_a?(Hash)
      quantity = params[:quantity][variant_id.to_i].to_i if params[:quantity].is_a?(Hash)
      @order.add_variant(Spree::Variant.find(variant_id), quantity) if quantity > 0
    end if params[:products]

    params[:variants].each do |variant_id, quantity|
      quantity = quantity.to_i
      @order.add_variant(Spree::Variant.find(variant_id), quantity) if quantity > 0
    end if params[:variants]

    fire_event('spree.cart.add')
    fire_event('spree.order.contents_changed')
    respond_with(@order) { |format| 
      format.html { 
        if request.xhr?
          render :partial => "spree/shared/mini_cart"
        else
          redirect_to cart_path 
        end
      }  
    }
  end
    
  protected
  
  def update_order_prices
    @order.update! if @order
  end
  
  
  def set_body_id
    @body_id = 'cart'
  end
  
end
