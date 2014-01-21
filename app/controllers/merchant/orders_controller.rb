class Merchant::OrdersController < Spree::Admin::OrdersController
  before_filter :authorized_store_member?
  before_filter :require_admin, :only => [:confirm_force_cancel, :force_cancel]
  #before_filter :check_for_past_due_items
  before_filter :use_jquery_16
  
  layout 'merchant'
  
  def index
    @store = Store.find(params[:store_id])
  
    @all_orders = @store.all_order_count
    @past_due_orders = @store.past_due_order_count
    # 3.1Break 
    @open_orders = @store.open_order_count
    #@open_orders = @all_orders
    @closed_late_orders = @store.closed_late_order_count
    @complete_orders = @store.complete_order_count
    @canceled_orders = @store.canceled_order_count
    @default_orders = @open_orders
    
    params[:search] ||= {}
    
    # need to find the following keys in case they were created for the sorting of columns
    # This is because I'd rather not override sort_link
    if params[:search][:number_contains]
      params[:search_key] = :order_number_like
      params[:search_content] = params[:search].delete(:number_contains)
    elsif params[:search][:bill_address_firstname_starts_with]
      params[:search_key] = :order_bill_address_firstname_starts_with
      params[:search_content] = params[:search].delete(:bill_address_firstname_starts_with)
    elsif params[:search][:bill_address_lastname_starts_with]
      params[:search_key] = :order_bill_address_lastname_starts_with
      params[:search_content] = params[:search].delete(:bill_address_lastname_starts_with)
    elsif params[:search][:email_contains]
      params[:search_key] = :order_email_like
      params[:search_content] = params[:search].delete(:email_contains)
    end
    
    #check_for_past_due_items(@store.id)
    
    #@all_orders = @store.all_order_count
    #@past_due_orders = @store.past_due_order_count
    #@open_orders = @store.open_order_count
    #@closed_late_orders = @store.closed_late_order_count
    #@complete_orders = @store.complete_order_count
    #@canceled_orders = @store.canceled_order_count
    #@default_orders = @store.default_order_count
    
    @sort_completed_at = false
    
    ###
    # In the following:
    #   params[:search][:state_equals] is used for the search box table
    #   params[:search][:state_in] is used for the actual query against the database
    #   params[:{state}_orders] is used for the green highlighted boxes
    ###
    @filter = if params[:open_orders] or params[:search][:state_equals] == 'open'
        params[:search][:state_equals] = "open"
        params[:search][:state_in] = ['open', 'past_due']
        params[:open_orders] = 1
        #orders = LineItem.distinct_by_store(@store.id).open.map {|item| item.order_id}
        @sort_completed_at = true
        #3.1 Break @store.orders_stores.open
      elsif params[:past_due_orders] or params[:search][:state_equals] == 'past_due'
        params[:search][:state_equals] = "past_due"
        params[:search][:state_in] = 'past_due'
        params[:past_due_orders] = 1
        #orders = LineItem.distinct_by_store(@store.id).past_due.map {|item| item.order_id}        
        @sort_completed_at = true
        @store.orders_stores.past_due
      elsif params[:complete_orders] or params[:search][:state_equals] == 'complete'
        params[:search][:state_equals] = "complete"
        params[:search][:state_in] = ['complete', 'closed_late']
        params[:complete_orders] = 1
        #orders = LineItem.distinct_by_store(@store.id).closed.map {|item| item.order_id}
        @sort_completed_at = true
        @store.orders_stores.complete
      elsif params[:closed_late_orders] or params[:search][:state_equals] == 'closed_late'
        params[:search][:state_equals] = "closed_late"
        params[:search][:state_in] = 'closed_late'
        params[:closed_late_orders] = 1
        #orders = LineItem.distinct_by_store(@store.id).closed_late.map {|item| item.order_id}
        @sort_completed_at = true
        @store.orders_stores.closed_late
      elsif params[:canceled_orders] or params[:search][:state_equals] == 'canceled'
        params[:search][:state_equals] = "canceled"
        params[:search][:state_in] = 'canceled'
        params[:canceled_orders] = 1
        #orders = LineItem.distinct_by_store(@store.id).canceled.map {|item| item.order_id}
        @sort_completed_at = true
        @store.orders_stores.canceled
      else
        params[:search][:state_is_not_null] = true
        params[:all_orders] = 1
        #orders = LineItem.distinct_by_store(@store.id).except_ready.map {|item| item.order_id}
        @sort_completed_at = true
        @store.orders_stores.active
    end
    #params[:search][:id_in] = (orders == []) ? [0] : orders # metasearch doesn't like an empty array.
    
    search_params = params[:search].dup
    if params[:search][:meta_sort].nil?
      params[:search][:meta_sort] = 'order_completed_at.asc'
    end
    if search_params[:meta_sort]
      search_params[:meta_sort].sub!(/^order_/, '')
    end
    
    if !params[:search_key].blank? and !params[:search_content].blank?
      search_key = params[:search_key]
      search_key = search_key.to_s.sub('order_', '').to_sym
      search_params[search_key] = params[:search_content]
    end
    
    @search = Spree::Order.metasearch(search_params)
    #@search = @store.orders_stores.metasearch(params[:search])
    
    @search_keys = {
      'First Name' => :order_bill_address_firstname_starts_with, 
      'Last Name' => :order_bill_address_lastname_starts_with, 
      'Order Number' => :order_number_like, 
      'Email' => :order_email_like 
    }
    @search_content = params[:search_content]
    search_dup = params[:search].clone
    
    search_dup.delete(:created_at_less_than)
    search_dup.delete(:created_at_greater_than)
    search_dup.delete(:state_equals)
    
    if !params[:search_key].blank? and !params[:search_content].blank?
      search_dup[params[:search_key]] = params[:search_content]
    end
    
    # Only do completed_at
    if !params[:search][:created_at_greater_than].blank?
      search_dup[:order_completed_at_greater_than] = Time.zone.parse(params[:search][:created_at_greater_than]).beginning_of_day rescue ""
    end
    
    if !params[:search][:created_at_less_than].blank?
      search_dup[:order_completed_at_less_than] = Time.zone.parse(params[:search][:created_at_less_than]).end_of_day rescue ""
    end
    
    if search_dup[:meta_sort] and search_dup[:meta_sort].starts_with?('completed_at')
      search_dup[:meta_sort] = "order_#{search_dup[:meta_sort]}"
    end
    
    #if @sort_completed_at
    #  search_dup[:order_completed_at_greater_than] = search_dup.delete(:order_created_at_greater_than)
    #  search_dup[:order_completed_at_less_than] = search_dup.delete(:order_created_at_less_than)
    #end
    
    #puts "params[:search] => #{params[:search]}"
    
    #puts "search dup => #{search_dup}"
    
    #puts "meta search => #{@filter.metasearch(search_dup).count}"
    
    #@orders = Spree::Order.metasearch(params[:search]).paginate(
    @metasearch = @filter.metasearch(search_dup)
    @orders = @metasearch.includes([:order => [:user, :bill_address, :shipments, :payments]]).page(params[:page]).per(Spree::Config[:orders_per_page])
    
    @total_reimbursement = @metasearch.sum(:total_reimbursement)

    respond_with(@orders)
  end
  
  def show
    @store = Store.find(params[:store_id])
    @order = Spree::Order.find_by_number(params[:id])
    
    redirect_to edit_merchant_store_order_path(@store, @order)
  end
  
  def edit
    @store = Store.find(params[:store_id])
    @order = Spree::Order.find_by_number(params[:id])
    
    @orders_store = @store.orders_stores.find_by_order_id(@order)
    #load_order
    @shipment = @orders_store.shipments.not_shipped.first
    @shipment = @orders_store.shipments.first if @shipment.blank?
    
    #@shipment = Shipment.by_order(@order.id).by_store(@store.id).not_shipped.first
    #@shipment = Shipment.by_order(@order.id).by_store(@store.id).first if @shipment.blank?
    @shipping_methods = Spree::ShippingMethod.all_available(@order, :back_end)
    respond_with(@order)
  end
  
  # How Shipments Work
  # 
  # Shipments work by first identifying the inventory units that were not shipped and collecting them
  # If there are inventory units that were not shipped, then those are updated into a new shipment
  # Then the current shipment is shipped
  #  - in after_ship, the remaining inventory units are sent ship!
  #  - those inventory units are marked as shipped, and they call their line items
  #  - their line items are then marked as shipped, if all inventory units have been shipped
  #  - then the line items call the orders store, if all line items are shipped, it marks as shipped
  #  - then if shipped, it updates the order
  def ship
    @store_id = params[:store_id]
    @store = Store.find(@store_id)
    if @store.nil?
      flash[:error] = "Store not found"
      return redirect_to account_path, :status => 404
    end
    @order = Spree::Order.find_by_number(params[:id])
    if @order.nil?
      flash[:error] = "Order not found"
      return redirect_to main_app.merchant_store_orders_path(@store), :status => 404
    end
    @orders_store = @store.orders_stores.find_by_order_id(@order.id)
    if @orders_store.nil?
      flash[:error] = "The orders store could not be found"
      return redirect_to edit_merchant_store_order_path(@store, @order), :status => 404
    end
    @shipment = Spree::Shipment.find(params[:shipment][:id])
    if @shipment.nil?
      flash[:error] = "Shipment not found"
      return redirect_to edit_merchant_store_order_path(@store, @order), :status => 404
    end
    
    if !params[:inventory_units].nil?
      if params[:shipment][:vendor_shipping_method].blank? or params[:shipment][:tracking].blank?
        flash[:error] = "You must add a shipping method and tracking number to claim the items as shipped"
        return render :edit
      end
      @shipment.vendor_shipping_method = params[:shipment][:vendor_shipping_method]
      @shipment.tracking = params[:shipment][:tracking]
      puts "**** shipping shipment #{@shipment.id}"
      
      shipped_ids = params[:inventory_units].collect {|values| values[0]}.delete_if {|value| value.nil? } # get the key
      
      unshipped_units = @shipment.inventory_units.not_shipped.where('inventory_units.id NOT IN (?)', shipped_ids)
      if !unshipped_units.empty?
        # now having @order.shipments create the new shipment, so that it is already attached to @order
        # previously it was just making it in the either and not having it get attached
        @new_shipment = @order.shipments.new(
          :shipping_method_id => Spree::Config[:second_shipment_method_id],
          :address_id => @shipment.address_id,
          :store_id => @store.id,
          :state => 'ready')
        @new_shipment.save(:validate => false)
        #@shipment.update_attribute_without_callbacks "state", "shipped"
        unshipped_units.limit(unshipped_units.count).update_all(shipment_id: @new_shipment.id)
      end
      
      @shipment.inventory_units.reload
      @shipment.ship!
      flash.notice = t('shipment_updated')
    else
      if @shipment.ready? and @shipment.inventory_units.not_shipped.not_canceled.count == 0
        @shipment.update_attributes_without_callbacks :state => 'shipped', :shipped_at => DateTime.now
      end
      @orders_store.shipped
    end
    redirect_to :action => :edit, :store_id => @store, :id => @order
  end

  def check_for_past_due_items
    if store = Store.find(params[:store_id])
      Spree::LineItem.by_store(store.id).not_shipped.not_canceled.each do |item|
        order = Spree::Order.find(item.order_id)
        item.update!(order)
      end
    end
  end
  
  def confirm_cancel_remaining
    @jquery_16 = true
    @body_id = "stores-account"
    @order = Spree::Order.find_by_number(params[:id])
    @store = Store.find(params[:store_id])
    if !@order.blank?
      @orders_store = @store.orders_stores.find_by_order_id(@order)
      if @orders_store.blank?
        flash[:error] = "Order for store not found."
        return redirect_to edit_merchant_store_order_path(@store, @order), :status => 404
      end
      @store = @orders_store.store
    else
      flash[:error] = "Error: Order not found"
      return redirect_to main_app.merchant_store_orders_path(@store)
    end
  end
  
  def cancel_remaining
    @order = Spree::Order.find_by_number(params[:id])
    @store = Store.find(params[:store_id])
    if !@order.blank?
      @orders_store = @store.orders_stores.find_by_order_id(@order)
      if @orders_store.blank?
        flash[:error] = "Order for store not found."
        return redirect_to edit_merchant_store_order_path(@store, @order), :status => 404
      end
      @orders_store.cancel_remaining!
      #@orders_store.line_items.each do |item|
      #  item.cancel!
      #end
      @order.reload
      Spree::OrderMailer.cancel_email(@order).deliver
      flash[:notice] = "Remaining items canceled." # even though it may be just for this store...
      redirect_to :action => :edit, :store_id => @store, :id => @order
    else
      flash[:error] = "Error: Order #{@order.number} not found"
      redirect_to main_app.merchant_store_orders_path(@store)
    end
  end
  
  def confirm_force_cancel
    @jquery_16 = true
    @body_id = "stores-account"
    @order = Spree::Order.find_by_number(params[:id])
    @store = Store.find(params[:store_id])
    if !@order.blank?
      @orders_store = @store.orders_stores.find_by_order_id(@order)
      if @orders_store.blank?
        flash[:error] = "Order for store not found."
        return redirect_to edit_merchant_store_order_path(@store, @order), :status => 404
      end
    else
      puts "params id is #{params[:id]}"
      flash[:error] = "Error: Order not found"
      redirect_to main_app.merchant_store_orders_path(@store)
    end
  end
  
  def force_cancel
    @order = Spree::Order.find_by_number(params[:id])
    @store = Store.find(params[:store_id])
    if !@order.blank?
      @orders_store = @store.orders_stores.find_by_order_id(@order)
      if @orders_store.blank?
        flash[:error] = "Order for store not found."
        return redirect_to edit_merchant_store_order_path(@store, @order), :status => 404
      end
      @orders_store.force_cancel!
      #@orders_store.line_items.each do |item|
      #  item.cancel!
      #end
      @order.reload
      Spree::OrderMailer.cancel_email(@order).deliver
      flash[:notice] = "All items in store's order force canceled." # even though it may be just for this store...
    else
      flash[:error] = "Error: Order #{@order.number} not found"
      return redirect_to main_app.merchant_store_orders_path(@store)
    end
    redirect_to :action => :edit, :store_id => @store, :id => @order
  end
  
  def cancel
    @order = Spree::Order.find_by_number(params[:id])
    @store = Store.find(params[:store_id])
    if !@order.blank?
      @orders_store = @store.orders_stores.find_by_order_id(@order)
      if @orders_store.blank?
        flash[:error] = "Order for store not found."
        return redirect_to edit_merchant_store_order_path(@store, @order), :status => 404
      end
      @orders_store.cancel_remaining!
      Spree::OrderMailer.cancel_email(@order).deliver
      flash[:notice] = "Order #{@order.number} canceled." # even though it may be just for this store...
    else
      flash[:error] = "Error: Order #{@order.number} not found"
      return redirect_to main_app.merchant_store_orders_path(@store)
    end
    redirect_to :action => :edit, :store_id => @store, :id => @order
  end
  
  def cancel_item
    @order = Spree::Order.find_by_number(params[:id])
    @store = Store.find(params[:store_id])
    if @order.blank?
      flash[:error] = "Order not found."
      return redirect_to main_app.merchant_store_orders_path(@store), :status => 404
    end
    @orders_store = @store.orders_stores.find_by_order_id(@order)
    if @orders_store.blank?
      flash[:error] = "Order for store not found."
      return redirect_to edit_merchant_store_order_path(@store, @order), :status => 404
    end
    @inventory_unit = @orders_store.inventory_units.find(params[:inventory_unit_id])
    if @inventory_unit.blank?
      flash[:error] = "Inventory Unit not found."
      return render :edit, :status => 404
    end
    @shipment = @inventory_unit.shipment#Shipment.find(params[:shipment_id])
    @inventory_unit.cancel!
    Spree::OrderMailer.cancel_email(@inventory_unit.order).deliver
    #OrderMailer.cancel_unit_email(@order, @inventory_unit.variant).deliver if !@order.line_items.by_variant(@inventory_unit.variant.id).first.canceled?
    flash[:notice] = "Item canceled."
    if @shipment.inventory_units.blank?
      redirect_to :action => :index, :store_id => @store
    else
      redirect_to :action => :edit, :store_id => @store, :id => @order
    end
  end
  
  protected
  
  def require_admin
    if !current_user.admin?
      flash[:error] = "You are not authorized to conduct that action"
      redirect_back_or_default account_path
    end
  end
  
  def use_jquery_16
    @jquery_16 = true
  end

end
