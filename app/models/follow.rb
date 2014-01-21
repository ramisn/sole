require 'model_request_info'
require 'post_to_facebook'

class Follow < ActiveRecord::Base
  # Need to access request object from controllers for current action
  include PostToFacebook
  
  # Need to access the url path creators
  include ApplicationHelper
  include ProfilesHelper
  
  belongs_to :follower, :polymorphic => true
  belongs_to :following, :polymorphic => true
  
  has_many :feed_items, :as => :feedable, :dependent => :destroy
  
  scope :active, where(:state => :active)
  scope :inactive, where(:state => :inactive)
  
  state_machine :state, :initial => :active do
    event :stop_following do
      transition :active => :inactive
    end
    event :follow do
      transition :inactive => :active
    end
  end
  
  # This posts on the wall of the follower that they are now following someone
  #def post_on_facebook!(options={})
  #  self.class.post_on_facebook!(follower, following, options)
  #end
  
  ###
  # For posting to Facebook
  ###
  
  def facebook_access_token(options={})
    if self.follower.is_a?(Spree::User)
      if self.follower.facebook_auth
        self.follower.facebook_auth.access_token
      end
    elsif self.follower.is_a?(Store)
      if self.current_user
        manager = self.follower.managers.find_by_user_id(self.current_user)
        if manager
          manager.facebook_access_token
        end
      else
        manager = self.follower.managers.first
        if manager
          manager.facebook_access_token
        end
      end
    end
  end
  
  # This is being posted to the followees wall
  def facebook_poster_id(options={})
    entity = if options[:post_to] == :follower
      self.follower
    else
      self.following
    end
    
    if entity.is_a?(Spree::User)
      if entity.facebook_auth
        entity.facebook_auth.uid
      end
    elsif entity.is_a?(Store)
      entity.facebook_id
    end
  end
  
  def facebook_name(options={})
    if self.following.is_a?(Store)
      "#{self.following.name_for_facebook}#{self.following.name_for_facebook.match(/Store$/) ? "" : "'s Store" }"
    else
      "#{self.follower.name_for_facebook}'s Profile"
    end
  end

  def facebook_message(options={})
    "#{self.following.name_for_facebook} is now being followed by #{self.follower.name_for_facebook} on Soletron"
  end
  
  def facebook_link(options={})
    # This should be changed to the person purchased products later
    facebook_domain_posted_from+entity_profile_path(self.following.is_a?(Store) ? self.following : self.follower)
  end
  
  def facebook_picture_to_use(options={})
    url_for_picture = profile_picture_url((self.following.is_a?(Store) ? self.following : self.follower), :size => :medium, :domain => facebook_domain_posted_from)
    
    # Couldn't get Facebook to use the image off of Heroku, so I put one up on Amazon.
    if url_for_picture.match(/fpo-profile.jpg$/)
      url_for_picture = "https://s3.amazonaws.com/SpreeHeroku/assets/static/fpo-profile-small.jpg"
    end
    
    url_for_picture
  end
  
  def facebook_description(options={})
    if self.following.is_a?(Store) and !self.following.about.blank?
      self.following.about
    elsif self.following.is_a?(Spree::User) and self.follower.about
      self.follower.about
    else
      "Soletron is a social marketplace and information source for exclusive sneakers, apparel, street art and the latest hip hop releases."
    end
  end

    
  class << self
    # Need to access request object from controllers for current action
    #include ModelRequestInfo::ModelMethods
    
    # Need to access the url path creators
    #include Rails.application.routes.url_helpers
    #include ApplicationHelper
    #include ProfilesHelper
    
    # follower_count takes an array of entities
    # it returns a hash with the key being an array like ['Spree::User', 1], where in the array, the first entry is
    # the name of the class and the second is the id of the entity
    
    def split_entities(entities)
      stores = []
      users = []
      entities.each do |entity|
        if entity.is_a?(Store)
          stores << entity.id
        elsif entity.is_a?(Spree::User)
          users << entity.id
        end
      end
      {:stores => stores, :users => users}
    end
    
    def followers_count(entities)
      opts = if entities.is_a?(Hash)
        opts
      else
        split_entities(entities)
      end
      where("(follows.following_type = ? AND follows.following_id IN (?)) OR (follows.following_type = ? AND follows.following_id IN (?))", 'Store', opts[:stores], 'Spree::User', opts[:users]).count(:group=>[:following_type, :following_id])
    end
    
  end
end
