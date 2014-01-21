class ConsolidatedFeedItem < ActiveRecord::Base
  belongs_to :feed_item
  belongs_to :consolidated, :polymorphic => true
  
  validates :feed_item, :presence => true
  validates :consolidated, :presence => true
end
