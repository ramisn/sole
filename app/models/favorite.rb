require 'post_to_facebook'

class Favorite < ActiveRecord::Base
  include PostToFacebook
  
  belongs_to :product, :class_name => "Spree::Product"
  belongs_to :user, :class_name => "Spree::User"
  
  has_one :feed_item, :as => :feedable, :dependent => :destroy
  # for the comments controller
  def feed_items
    feed_item
  end
  
  has_one :consolidated_feed_item, :as => :consolidated, :dependent => :destroy
  
  validates :product_id, :uniqueness => {:scope => :user_id, :message => "You have already favorited this product."}
  
  
  
  ###
  # For posting to Facebook
  #
  # If a feed item is found, it defaults to posting the data for the last consolidated favorite
  # with the number of ther additions.
  #
  # It is written this way because currently the post will happen with consolidated favorites only at the
  # daily posting, whereas it will post immediately (no consolidated favorites) when the feed item
  # is created.
  ###
  
  def facebook_access_token(options={})
    if self.user.facebook_auth
      self.user.facebook_auth.access_token
    end
  end
  
  def facebook_poster_id(options={})
    if self.user.facebook_auth
      self.user.facebook_auth.uid
    end
  end
  
  def facebook_product_to_name(options={})
    @facebook_product_to_name ||= if self.feed_item and self.feed_item.consolidated_feed_items.count == 1
      self.feed_item.consolidate_feed_items[0].consolidated
    elsif self.feed_item and self.feed_item.consolidated_feed_items.count > 1
      self.feed_item.consolidated.order('created_at DESC').limit(1).first.consolidated
    else
      self.product
    end

  end
  
  def facebook_name(options={})
    facebook_product_to_name.name
  end

  def facebook_message(options={})
    more_message = if self.feed_item and self.feed_item.consolidated_feed_items.count == 1
      " and 1 more item"
    elsif self.feed_item and self.feed_item.consolidated_feed_items.count > 1
      " and #{self.feed_item.consoldiated_feed_items.count} more items"
    else
      ""
    end
    
    "#{self.user.name} has added #{facebook_product_to_name.name}#{more_message} as a favorite item on Soletron"
  end
  
  def facebook_link(options={})
    facebook_domain_posted_from+product_path(facebook_product_to_name)
  end
  
  def facebook_picture_to_use(options={})
    facebook_product_to_name.images.empty? ? facebook_domain_posted_from+"/assets/noimage/product.jpg" : facebook_product_to_name.images.first.attachment.url(:product)
  end
  
  def facebook_description(options={})
    facebook_product_to_name.description
  end
end
