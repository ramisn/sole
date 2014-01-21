class CommentObserver < ActiveRecord::Observer
  include FeedObserver
  include NotifierObserver
  
  def after_create(observed)
    create_feed_items(observed)
    create_notifications(observed)
  end
  
  def entities_to_notify(observed)
    notified_so_far = {}
    Comment.not_commenter(observed.commenter).not_commenter(observed.feed_item.displayable).where(:feed_item_id => observed.feed_item.feedable.feed_items).includes(:commenter).inject([]) do |array, comment|
      if !notified_so_far.has_key?(comment.commenter)
        array << comment.commenter
        notified_so_far[comment.commenter] = comment
      end
      array
    end+(observed.commenter != observed.feed_item.displayable ? [observed.feed_item.displayable] : [])
  end
  
  def initiator(observed)
    observed.commenter
  end
  
  def entities_to_post_to(observed)
    observed.commenter
  end
end
