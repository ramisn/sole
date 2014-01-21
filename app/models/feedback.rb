class Feedback < ActiveRecord::Base
  belongs_to :order, :class_name => "Spree::Order"
  belongs_to :store
  
  validates :store_id, :uniqueness => {:scope => :order_id}
  validates :rating, :presence => true, :on => :update
  validates :message, :presence => true, :on => :update
  
  state_machine :initial => :needed do
    event :added do
      transition :needed => :done
    end
  end
  
  scope :needed, where(:state => :needed)
  scope :done, where(:state => :done)
end
