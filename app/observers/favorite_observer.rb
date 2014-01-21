require 'model_request_info'

class FavoriteObserver < ActiveRecord::Observer
  include FeedObserver
  include NotifierObserver
  
  def after_create(observed)
    last_feed_item = FeedItem.where(:feedable_type => 'Favorite', :displayable_type => 'User', :displayable_id => observed.user).where("feed_items.created_at > ?", 2.hours.ago).order('feed_items.created_at DESC').limit(1)[0]
    if last_feed_item
      last_feed_item.consolidated_feed_items.create(:consolidated => observed)
    else
      post_to_facebook(observed)
      create_feed_items(observed)
    end
    
    create_notifications(observed)
    Delayed::Job.enqueue FavoriteJob.new(observed.id)
  end
  
  def post_to_facebook(observed)
    observed.post_to_facebook
  end
  
  def entities_to_notify(observed)
    [observed.product.store]+observed.user.entity_followers
  end
  
  def initiator(observed)
    observed.user
  end
  
  def entities_to_post_to(observed)
    observed.user
  end
end
