class Shoutout < ActiveRecord::Base
  
  belongs_to :poster, :polymorphic => true
  belongs_to :posted_to, :polymorphic => true
  
  has_many :feed_items, :as => :feedable, :dependent => :destroy
  
  validates :content, :presence => true
  
  def content_to_html
    self.content.split("\n").join('<br/><br/>')
  end
end
