class ProductObserver < ActiveRecord::Observer
  
  observe Spree::Product
  
  include ModelRequestInfo::ModelMethods
  include Rails.application.routes.url_helpers
  include ApplicationHelper
  include ProfilesHelper
  include FeedObserver
  include NotifierObserver
  
  def after_publish_to_published(observed)#, transition)
    last_feed_item = FeedItem.where(:feedable_type => 'Spree::Product', :displayable_type => 'Store', :displayable_id => observed.store_taxon.store).where("feed_items.created_at > ?", 2.hours.ago).order('feed_items.created_at DESC').limit(1)[0]
    if last_feed_item
      last_feed_item.consolidated_feed_items.create(:consolidated => observed)
    else
      create_feed_items(observed)
      post_to_facebook(observed)
    end
    create_notifications(observed)
  end
  
  def post_to_facebook(observed)
    observed.post_to_facebook
  end
  
  def entities_to_notify(observed)
    observed.store.entity_followers
  end
  
  def initiator(observed)
    observed.store
  end
  
  def entities_to_post_to(observed)
    observed.store
  end
  
end
