module FeedObserver
  # expects function entities_to_post_to to be defined
  
  def create_feed_items(observed)
    posting_to = entities_to_post_to(observed)
    if !posting_to.is_a?(Array)
      posting_to = [posting_to]
    end
    
    posting_to.each do |entity|
      if entity
        entity.feed_items.create(:feedable => observed, :initiator => initiator(observed))
      end
    end
  end
  
  def initiator(observed)
    raise "initiator not implemented! #{self.class.name}"
  end
  
  def entities_to_post_to(observed)
    raise "entities_to_post_to not implemented! #{self.class.name}"
  end
end
