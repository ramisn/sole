class UserProduct < Spree::Product
  include PostToFacebook
  belongs_to :user, :class_name => "Spree::User"
  #has_many :images, :as => :viewable, :order => :position, :dependent => :destroy
  
  # for user uploads
  accepts_nested_attributes_for :images
  accepts_nested_attributes_for :product_option_types
  
  ###
  # This state machine could be hooked into the finish button on product additions and set the 
  # product to being published.
  ###
  state_machine :state, :initial => :user
  
  def store_taxon
    raise "user product does not have a store taxon!"
  end
  
  def to_param
    "#{self[:id]}-"+super
  end
  
  ###
  # For posting to Facebook
  #
  # If a feed item is found, it defaults to posting the data for the last consolidated product
  # with the number of ther additions.
  #
  # It is written this way because currently the post will happen with consolidated products only at the
  # daily posting, whereas it will post immediately (no consolidated products) when the feed item
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
      self
    end

  end
  
  def facebook_name(options={})
    facebook_product_to_name(options).name
  end

  def facebook_message(options={})
    more_message = if self.feed_item and self.feed_item.consolidated_feed_items.count == 1
      " and 1 more item"
    elsif self.feed_item.consolidated_feed_items.count > 1
      " and #{self.feed_item.consoldiated_feed_items.count} more items"
    else
      ""
    end
    
    "#{self.user.name} has just added #{facebook_product_to_name(options).name}#{more_message} to their collection on Soletron"
  end
  
  def facebook_link(options={})
    facebook_domain_posted_from+uploaded_member_collection_path(self.user)#product_path(facebook_product_to_name(options))
  end
  
  def facebook_picture_to_use(options={})
    facebook_product_to_name(options).images.empty? ? facebook_domain_posted_from+"/assets/noimage/product.jpg" : facebook_product_to_name(options).images.first.attachment.url(:product)
  end
  
  def facebook_description(options={})
    facebook_product_to_name(options).description
  end
  
  protected
  
  def sanitize_permalink
    self.permalink = "#{self.id}-#{self.name.to_url}"
  end
end
