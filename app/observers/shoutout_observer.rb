class ShoutoutObserver < ActiveRecord::Observer
  include FeedObserver
  include NotifierObserver
  
  def after_create(observed)
    create_feed_items(observed)
    create_notifications(observed)
  end
  
  def entities_to_notify(observed)
    if observed.poster != observed.posted_to
      observed.posted_to
    end
  end
  
  def initiator(observed)
    observed.poster
  end
  
  def entities_to_post_to(observed)
    [observed.poster]+(observed.poster != observed.posted_to ? [observed.posted_to] : [])
  end
end
