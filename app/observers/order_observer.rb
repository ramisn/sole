require 'model_request_info'

class OrderObserver < ActiveRecord::Observer
  
  observe Spree::Order
  
  include ModelRequestInfo::ModelMethods
  include FeedObserver
  include NotifierObserver
  
  def before_force_cancel_to_canceled(observed, transition=nil)
    observed.orders_stores.each do |orders_store|
      orders_store.force_cancel! if !orders_store.canceled?
    end
  end
  
  def after_transition_state_to_canceled(observed, transition=nil)
    observed.update_attributes_without_callbacks(:canceled_at => Time.now.utc, :canceled_by => current_user, :shipment_state => 'canceled')
    observed.shipments.not_shipped.each do |shipment|
      shipment.update_attribute_without_callbacks('state', 'canceled')
    end
  end
  
  def after_next_to_complete(observed, transition=nil)
    create_feed_items(observed)
    create_notifications(observed)
    post_to_facebook(observed)
    
    observed.stores.each do |store|
      observed.feedbacks.create(:store => store)
    end
    ###
    # Now ensured in calculate_orders_stores
    # Now calculated on an update to the order
    ###
    observed.line_items.each {|li| li.update_attribute_without_callbacks :state, 'open'}
    observed.ensure_all_orders_stores
    observed.calculate_orders_stores
    observed.lock_line_item_commission_percentages
    observed.open_orders_stores
    # Notify stores that they have a pending order.
    observed.notify_stores_of_order
  end
  
  def post_to_facebook(observed)
    observed.post_to_facebook
  end
  
  def entities_to_notify(observed)
    observed.user.entity_followers
  end
  
  def initiator(observed)
    observed.user
  end
  
  def entities_to_post_to(observed)
    observed.user
  end
  
end
