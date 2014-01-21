require 'model_request_info'

class LineItemObserver < ActiveRecord::Observer
  observe Spree::LineItem
  
  include ModelRequestInfo::ModelMethods
  
  def before_force_cancel(observed)
    observed.inventory_units.not_shipped.each do |inventory_unit|
      inventory_unit.update_attribute_without_callbacks :state, 'canceled'
    end
    observed.quantity = 0
    observed.save(:validate => false)
  end
  
  def after_transition_state_to_canceled(observed)
    #puts "transitioned to canceled"
    observed.update_attributes_without_callbacks(:state => 'canceled', :canceled_at => Time.now.utc, :canceled_by => current_user)
    observed.orders_store.cancel
    observed.order.calculate_orders_stores
  end
  
  def after_transition_state_to_shipped(observed)
    observed.update_attribute_without_callbacks 'state', 'shipped'
    observed.orders_store.line_items.reload
    observed.orders_store.shipped
  end
  
  #def after_cancel_to_canceled(observed)
  #  #observed.order.inventory_units.decrease(observed.order, observed.variant, observed.quantity) if !observed.order.inventory_units.blank?
  #  observed.orders_store.cancel 
  #end
  #
  #def after_soft_cancel_to_canceled(observed)
  #  #observed.order.inventory_units.decrease(observed.order, observed.variant, observed.quantity) if !observed.order.inventory_units.blank?
  #  #observed.save
  #  puts "line item observer #{observed.inspect}"
  #  puts "line item observer reload #{observed.reload.inspect}"
  #  observed.orders_store.cancel
  #end
  #
  #def after_force_cancel_to_canceled(observed)
  #  observed.orders_store.cancel
  #end
  
  def after_create(observed)
    observed.order.ensure_orders_store(observed.store)
  end
  
  def after_destroy(observed)
    observed.order.check_to_remove_orders_store(observed.store)
  end
  
end
