require 'model_request_info'

class InventoryUnitObserver < ActiveRecord::Observer
  observe Spree::InventoryUnit
  
  include ModelRequestInfo::ModelMethods
  
  # un-dryed this code, because line item's soft cancel wasn't properly bubbling up.
  def after_transition_state_to_canceled(observed, transition=nil)
    #puts "iu is #{observed.inspect}"
    observed.update_attributes_without_callbacks(:canceled_at => Time.now.utc, :canceled_by => current_user)
    
    observed.line_item.reload
    
    observed.shipment.cancel
    #puts "shipment is now #{observed.shipment.inspect}"
    line_item = observed.line_item
    line_item.decrement_quantity
    line_item.save(:validate => false)
    line_item.variant.increment!(:count_on_hand, 1) if Spree::Config[:track_inventory_levels]
    #decrement_line_item(line_item)
    line_item.soft_cancel
    line_item.order.reload
    observed.order.line_items.reload
    observed.order.update!
    observed.order.calculate_orders_stores
  end
  
  def after_transition_state_to_shipped(observed)
    observed.update_attribute_without_callbacks 'state', 'shipped'
    observed.line_item.inventory_units.reload
    observed.line_item.ship
  end
  
  #def after_force_cancel_to_canceled(observed, transition=nil)
  #  observed.shipment.update_attribute_without_callbacks 'state', :canceled if observed.shipment.all_inventory_units_canceled?
  #  line_item = observed.line_item
  #  decrement_line_item(line_item)
  #  line_item.update_attribute_without_callbacks 'state', :canceled if line_item.all_inventory_units_canceled?
  #  line_item.order.reload
  #  observed.order.line_items.reload
  #  line_item.orders_store.update_attribute_without_callbacks 'state', :canceled if line_item.orders_store.all_items_canceled?
  #  line_item.orders_store.order.update_attribute_without_callbacks 'state', :canceled if line_item.orders_store.order.all_items_canceled?
  #  observed.order.update!
  #  observed.order.calculate_orders_stores
  #end
  
  #def decrement_line_item(line_item)
  #  line_item.decrement_quantity
  #  line_item.save(:validate => false)
  #  line_item.variant.increment!(:count_on_hand, 1) if Spree::Config[:track_inventory_levels]
  #end
  
end
