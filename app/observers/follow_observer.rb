class FollowObserver < ActiveRecord::Observer
  include FeedObserver
  include NotifierObserver
  #include ActionController::Flash
  
  def after_create(observed)
    execute_actions(observed)
  end
  
  def after_follow(observed, transition)
    execute_actions(observed)
  end
  
  def execute_actions(observed)
    create_feed_items(observed)
    create_notifications(observed)
    succeeded = post_to_facebook(observed)
    if observed.following.is_a?(Store) or !succeeded
      post_to_facebook(observed, :post_to => :follower)
    end
    Delayed::Job.enqueue FollowJob.new(observed.id)
  end
  
  def after_stop_following(observed, transition)
    observed.feed_items.each {|item| item.destroy}
  end
  
  def post_to_facebook(observed, options={})
    observed.post_to_facebook(options)
  end
  
  def entities_to_notify(observed)
    [observed.following]+observed.follower.entity_followers.inject([]) do |array, follower|
      if follower != observed.following
        array << follower
      end
      array
    end
  end
  
  def initiator(observed)
    observed.follower
  end
  
  def entities_to_post_to(observed)
    [observed.follower, observed.following]
  end
  
end
