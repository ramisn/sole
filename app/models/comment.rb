class Comment < ActiveRecord::Base
  
  belongs_to :commenter, :polymorphic => true
  belongs_to :feed_item
  
  has_many :feed_items, :as => :feedable, :dependent => :destroy
  
  scope :not_commenter, Proc.new {|entity| {:conditions => "NOT (comments.commenter_type='#{entity.class.name}' AND comments.commenter_id=#{entity.id.to_i})"}}
  
  def message_to_html
    self.message.split("\n").join('<br/><br/>')
  end
  
end
