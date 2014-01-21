require 'model_request_info'

class ShipmentObserver < ActiveRecord::Observer
  
  observe Spree::Shipment
  
  include ModelRequestInfo::ModelMethods
  
  def after_force_cancel_to_canceled(observed, transition=nil)
    observed.update_attributes_without_callbacks(:canceled_at => Time.now.utc, :canceled_by => current_user)
    observed.inventory_units.each do |inventory_unit|
      inventory_unit.update_attributes_without_callbacks(:state => 'canceled', :canceled_at => Time.now.utc, :canceled_by => current_user)
      if inventory_unit.line_item
        inventory_unit.line_item.decrement_quantity
        inventory_unit.line_item.save(:validate => false)
        inventory_unit.line_item.variant.increment!(:count_on_hand, 1) if Spree::Config[:track_inventory_levels]
      end
    end
  end
  
end