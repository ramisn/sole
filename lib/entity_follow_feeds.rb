module EntityFollowFeeds
  module ClassMethods
    def relate
      has_one   :profile_image, :as => :viewable, :dependent => :destroy
      has_many  :followers, :as => :following, :class_name => 'Follow', :dependent => :destroy
      has_many  :following, :as => :follower, :class_name => 'Follow', :dependent => :destroy
      has_many  :feed_items, :as => :displayable, :dependent => :destroy
      has_many  :shouted_at, :as => :posted_to, :class_name => 'Shoutout', :dependent => :destroy
      has_many  :shoutouts, :as => :poster, :dependent => :destroy
      has_many  :notifications, :as => :notifying, :dependent => :destroy
    end
  end
  
  def self.included(base)
    base.extend(ClassMethods).relate
  end
  
  def is_following?(entity)
    item = following_item(entity)
    item and item.active?
  end
  
  def following_item(entity)
    self.following.find(:first, :conditions => {:follower_type => self.class.name, :follower_id => self[:id], :following_type => entity.class.name, :following_id => entity[:id]})
  end
  
  def my_feed_items(options={})
    page      = (options[:page] ? options[:page].to_i : 0)
    per_page  = 30 
    #3.1Break with kaminari offset = page * FeedItem.per_page
    offset = page * per_page
    #if self.feed_items.count > offset
      FeedItem.only_unique_feedables(self.feed_items.includes(:displayable, :feedable).order('created_at DESC').limit(per_page).offset(offset))
      # end
  end
  
  def entities_following
    self.following.active.includes(:following).inject([]) do |array, follow|
      array << follow.following
      array
    end
  end
  
  def entity_followers
    self.followers.active.includes(:follower).inject([]) do |array, follow|
      array << follow.follower
      array
    end
  end
  
  def network_feed_items(options={})
    following = entities_following
    page = (options[:page] ? options[:page].to_i : 0)
    offset = page * FeedItem.per_page
    #if FeedItem.combined_feed(following).count > offset
      FeedItem.only_unique_feedables(FeedItem.combined_feed(following).includes(:displayable, :feedable).order('created_at DESC').limit(FeedItem.per_page).offset(offset))
    #end
  end
  
  def all_feed_items(options={})
    following = entities_following
    page = (options[:page] ? options[:page].to_i : 0)
    offset = page * FeedItem.per_page
    #puts "\n\nfeed item number: #{FeedItem.combined_feed(following+[self]).count}\n\n"
    #if FeedItem.combined_feed(following+[self]).count > offset
      FeedItem.only_unique_feedables(FeedItem.combined_feed(following+[self]).includes(:displayable, :feedable).order('created_at DESC').limit(FeedItem.per_page).offset(offset))
    #end
  end
  
  def my_feed_items_count(options={})
    self.feed_items.count
  end
  
  def network_feed_items_count(options={})
    FeedItem.combined_feed(entities_following).count
  end
  
  def all_feed_items_count(options={})
    FeedItem.combined_feed(entities_following+[self]).count
  end
end
