class FeedItem < ActiveRecord::Base
  
  paginates_per 20
  
  belongs_to :displayable, :polymorphic => true
  belongs_to :feedable, :polymorphic => true
  belongs_to :initiator, :polymorphic => true
  
  has_many :comments, :dependent => :destroy
  
  has_many :consolidated_feed_items

  def self.per_page
    20
  end
  
  def self.combined_feed(entities)
    opts = if entities.is_a?(Hash)
      entities
    else
      Follow.split_entities(entities)
    end
    #where("(feed_items.displayable_type = ? AND feed_items.displayable_id IN (?)) OR (feed_items.displayable_type = ? AND feed_items.displayable_id IN (?))", 'Store', opts[:stores], 'User', opts[:users])
    where("((feed_items.displayable_type = ? AND feed_items.displayable_id IN (?)) OR (feed_items.displayable_type = ? AND feed_items.displayable_id IN (?))) AND (feed_items.initiator_id=feed_items.displayable_id AND feed_items.initiator_type=feed_items.displayable_type)", 'Store', opts[:stores], 'User', opts[:users])
  end
  
  # Since Postgresql wasn't playing well with using .group([:feedable_type, :feedable_id]), this method was created
  # so that only unique feedables are returned in each batch
  def self.only_unique_feedables(feed_items)
    if feed_items
      unique_feed_items = []
      unique_feedables = {}
      consolidating = {}
      
      feed_items.each do |feed_item|
        if !unique_feedables.has_key?(feed_item.feedable_type) 
          unique_feedables[feed_item.feedable_type] = {}
        end
        if !unique_feedables[feed_item.feedable_type].has_key?(feed_item.feedable_id)
          # Make sure that the unique feedables hash is set for this type
          #add_item = true
          
          # The types of feed items that will consolidate are Product and Favoirte
          #if feed_item.feedable.is_a?(Product) or feed_item.feedable.is_a?(Favorite)
          #  if !consolidating[feed_item.feedable_type]
          #    # If there is no existing consolidating item, make this one it
          #    consolidating[feed_item.feedable_type] = feed_item
          #  elsif !consolidating[feed_item.feedable_type].consolidate_item(feed_item)
          #    # since the item was not successfully considated, set it as the new consolidating item
          #    consolidating[feed_item.feedable_type] = feed_item
          #  else
          #    # in this case, the feed_item was consolidated, so don't add it to the list of unique feed items
          #    add_item = false
          #  end
          #end
          
          # unless this item has been flagged to not add, add it to unique feed items
          #if add_item
          unique_feedables[feed_item.feedable_type][feed_item.feedable_id] = feed_item
          unique_feed_items << feed_item
          #end
        end
      end
      unique_feed_items
    end
  end
  
  def self_and_siblings
    self.feedable.feed_items
    #FeedItem.where(:feedable_type => self.feedable_type, :feedable_id => self.feedable_id)
  end
  
  def self_and_sibling_comments
    Comment.where(:feed_item_id => self.self_and_siblings)
  end
  
  def count_comments
    case self.feedable
    when Shoutout
      self.self_and_sibling_comments.count
    else
      self.comments.count
    end
  end
  
  def consolidate_item(feed_item)
    if @consolidated_items.nil?
      @consolidated_items = []
    end
    if @consolidated_items.size < 2 and ((feed_item.feedable.is_a?(Favorite) and feed_item.feedable.user == self.feedable.user) or (feed_item.feedable.is_a?(Product) and feed_item.feedable.store_taxon.store == self.feedable.store_taxon.store))
      @consolidated_items << feed_item
    else
      false
    end
  end
  
  def consolidated_items
    @consolidated_items
  end
  
  def atom_title
    case self.feedable
    when Shoutout
      "#{self.feedable.poster.display_name} posted a shoutout to #{self.feedable.posted_to.display_name}'s feed"
    when Follow
      "#{self.feedable.follower.display_name} is now following #{self.feedable.following.display_name}"
    when Comment
      "#{self.feedable.commenter.display_name} posted a comment"
    end
  end
  
  def atom_content
    case self.feedable
    when Shoutout
      self.feedable.content_to_html
    when Follow
      "#{self.feedable.follower.display_name} is now following #{self.feedable.following.display_name}"
    when Comment
      self.feedable.message_to_html
    end
  end
  
  def atom_author_name
    case self.feedable
    when Shoutout
      self.feedable.poster.display_name
    when Follow
      self.feedable.follower.display_name
    when Comment
      self.feedable.commenter.display_name
    end
  end
  
  def self.post_daily_activity_to_facebook
    self.where(:feedable_type => ['Favorite','Product','Order']).where("created_at > ?", 24.hours.ago).includes([:feedable, :consolidated_feed_items]).each do |feed_item|
      feed_item.feedable.post_to_facebook
    end
  end
end
