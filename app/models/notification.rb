class Notification < ActiveRecord::Base
  belongs_to :notifying, :polymorphic => true
  belongs_to :item, :polymorphic => true
  
  
  scope :not_viewed, where(:state => :not_viewed)
  scope :viewed, where(:state => :viewed)
  
  state_machine :state, :initial => :not_viewed do
    event :viewing do
      transition :not_viewed => :viewed
    end
    event :new_again do
      transition :viewed => :not_viewed
    end
  end
  
  def viewed?
    self.state == :viewed
  end
end
