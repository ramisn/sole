module NotifierObserver
  def create_notifications(observed)
    posting_to = entities_to_notify(observed)
    if !posting_to.is_a?(Array)
      posting_to = [posting_to]
    end
    
    posting_to.each do |entity|
      if entity
        entity.notifications.create(:item => observed)
      end
    end
  end
  
  def entities_to_notify(observed)
    raise "entities_to_notify not implemented! #{self.class.name}"
  end
end
