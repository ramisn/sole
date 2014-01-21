class FeedbackObserver < ActiveRecord::Observer
  def before_added_to_done(observed)
    observed.feedback_left_at = Time.now.utc
  end
  
  def after_update(observed)
    update_store_feedback_rating(observed)
  end
  
  def after_destroy(observed)
    update_store_feedback_rating(observed)
  end
  
  protected
  
  def update_store_feedback_rating(observed)
    observed.store.update_attributes(:feedback_rating => observed.store.feedbacks.done.average(:rating))
  end
end
