class UserProductObserver < ActiveRecord::Observer
  
  observe UserProduct 
  
  include ModelRequestInfo::ModelMethods
  include FeedObserver
  include NotifierObserver
  
  def before_validation(observed)
    if observed.price.nil?
      observed.price = 0
    end
  end
  
  def after_create(observed)
    last_feed_item = FeedItem.where(:feedable_type => 'Spree::Product', :displayable_type => 'Spree::User', :displayable_id => observed.user.id).where("feed_items.created_at > ?", 2.hours.ago).order('feed_items.created_at DESC').limit(1)[0]
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
    observed.user.entity_followers
  end
  
  def initiator(observed)
    observed.user
  end
  
  def entities_to_post_to(observed)
    observed.user
  end
  
end
