module Merchant::OrderHelper

  def merchant_order_status(order, store_id)
    status = (order.line_items.by_store(@store.id).map {|item| item.state}).uniq
    case 
      when status.index("past_due") # any past due
        return 'Past Due ' + distance_of_time_in_words_to_now(order.completed_at + (Spree::Config[:shipment_late].to_i.days), include_seconds = false)
      when status.index("open") # any open
        return 'Open'
      when status.index("closed_late") # any shipped late with all others canceled
        return 'Shipped Late'
      when status.index("closed") # any closed with all others canceled.
        return 'Shipped'
      when (status.index("canceled") and status.length == 1) # all canceled
        return 'Canceled'
      else
        return 'Unknown'
    end
  end

  def is_selected(params, key)
    if params.nil? || params.empty?
      ""
    else
      if params.has_key?(key)
        "selected"
      elsif params[:search].has_key?(:state_is_not_null) and params[:search][:state_is_not_null] == 1
        "selected"
      elsif params[:search].has_key?(:state_equals) and 
           (params[:search][:state_equals] == "open" and key == :open_orders) or
           (params[:search][:state_equals] == "past_due" and key == :past_due_orders) or 
           (params[:search][:state_equals] == "complete" and key == :complete_orders) or 
           (params[:search][:state_equals] == "closed_late" and key == :closed_late_orders) or 
           (params[:search][:state_equals] == "canceled" and key == :canceled_orders)
        "selected"
      else
        ""
      end
    end
  end

  def get_orders_type(params)
    init_order_types

    @order_types.each do |key, value|
      if params.has_key?(key)
        return ":: " + value[:name]
      end
    end

    ""
  end

  def orders_link(params, type)
    init_order_types

    if type == :default
      use_path = main_app.merchant_store_orders_path
    else
      use_path = main_app.merchant_store_orders_path(type => 1)
    end
    link_to " #{@order_types[type][:name]}" + ' (' + @order_types[type][:object].to_s + ')', use_path, :class => is_selected(params, type)
  end

  private

  def init_order_types
    return @order_types if @order_types.present?

    @order_types = Hash[:all_orders, { :name => "All Orders", :object => @all_orders },
                        :open_orders, { :name => "Open Orders", :object => @open_orders },
                        :past_due_orders, { :name => "Past Due Orders", :object => @past_due_orders },
                        :complete_orders, { :name => "Complete Orders", :object => @complete_orders },
                        :closed_late_orders, { :name => "Complete Orders - Late", :object => @closed_late_orders },
                        :canceled_orders, { :name => "Canceled Orders", :object => @canceled_orders },
                        :default, { :name => "Default", :object => @default_orders } ]

  end

end
