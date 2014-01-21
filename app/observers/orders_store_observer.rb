require 'model_request_info'

class OrdersStoreObserver < ActiveRecord::Observer
  include ModelRequestInfo::ModelMethods
  
  def before_cancel_remaining(observed, transition=nil)
    observed.shipments.not_shipped.each do |shipment|
      shipment.force_cancel!
    end

    observed.inventory_units.not_shipped.each do |inventory_unit|
      inventory_unit.force_cancel!
      inventory_unit.update_attributes_without_callbacks(:canceled_at => Time.now.utc, :canceled_by => current_user) if inventory_unit.canceled?
    end

    observed.line_items.not_shipped.each do |line_item|
      not_canceled_count = line_item.inventory_units.not_canceled.count
      new_state = if not_canceled_count == 0
        'canceled'
      elsif Time.now.utc - line_item.order.completed_at >= 2.days
        'closed_late'
      else
        'complete'
      end
      line_item.update_attributes_without_callbacks 'state' => new_state, 'quantity' => not_canceled_count
      line_item.update_attributes_without_callbacks(:canceled_at => Time.now.utc, :canceled_by => current_user) if line_item.canceled?
    end
    observed.line_items.reload
  end
  
  def after_cancel_remaining(observed, transition=nil)
    observed.order.update!
    observed.order.calculate_orders_stores
  end
  
  def after_transition_state_to_canceled(observed, transition=nil)
    observed.update_attributes_without_callbacks(:canceled_at => Time.now.utc, :canceled_by => current_user)
    ## Need to transition shipments to canceled
    observed.shipments.not_shipped.each do |shipment|
      shipment.update_attribute_without_callbacks('state', 'canceled')
    end
    observed.order.cancel
    observed.order.calculate_orders_stores
  end
  
  def after_transition_state_to_complete(observed, transition=nil)
    update_completed_at(observed, 'complete')
    VendorPaymentPeriod.check_orders_store_for_period(observed)
    observed.order.orders_stores.reload
    observed.order.update!
  end
  
  def after_transition_state_to_closed_late(observed, transition=nil)
    update_completed_at(observed, 'closed_late')
    VendorPaymentPeriod.check_orders_store_for_period(observed)
    observed.order.update!
  end
  
  def before_force_cancel(observed, transition=nil)
    observed.inventory_units.not_shipped.each do |inventory_unit|
      inventory_unit.update_attribute_without_callbacks :state, 'canceled'
    end
    
    observed.line_items.each do |line_item|
      line_item.update_attribute_without_callbacks :state, 'canceled'
      line_item.update_attribute_without_callbacks :quantity, 0
    end
  end
  
  def after_force_cancel(observed, transition=nil)
    observed.order.update!
    observed.order.calculate_orders_stores
  end
  
  def update_completed_at(observed, state)
    observed.update_attributes(:completed_at => observed.shipments.order('shipped_at DESC').limit(1).first.shipped_at, :state => state)
  end
  
end
