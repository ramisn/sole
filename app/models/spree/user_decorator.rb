require 'entity_follow_feeds'

Spree::User.class_eval do
  include EntityFollowFeeds
  devise :confirmable
  
  paginates_per 30

  has_many :user_authentications, :dependent => :destroy

  #has_many :as_merchant, :dependent => :destroy
  has_many :stores_users, :dependent => :destroy
  has_many :stores, :through => :stores_users

  has_many :notifications, :as => :notifying, :dependent => :delete_all
  has_many :favorites, :dependent => :delete_all
  has_many :uploaded_products, :class_name => 'UserProduct'
  
  has_many :favorited_products, :through => :favorites, :source => :product, :class_name => 'Spree::Product'
  # Virtual attribute for authenticating by either username or email (devise)
  attr_accessor :login
  attr_accessor :return_url
  
  
  searchable do 
    text :username
  end

  attr_accessible :about
  attr_accessible :name
  attr_accessible :username
  attr_accessible :login
  attr_accessible :gender
  attr_accessible :current_city
  attr_accessible :birthday
  attr_accessible :opt_in_email
  attr_accessible :confirmation_token
  attr_accessible :confirmed_at
  attr_accessible :favorite_brands
  attr_accessible :favorite_sneakers
  attr_accessible :favorite_street_shops
  attr_accessible :facebook_manage_pages
  attr_accessible :receive_emails

  scope :latest, order('users.updated_at DESC')
  scope :oldest, order('users.updated_at ASC')
  scope :viewable, where("email NOT LIKE '%example.net'")
  
  alias_attribute :location ,:current_city

  validates :username,
    :presence => true,
    :length => {:minimum => 3, :maximum => 20},
    :uniqueness => true,
    :format => {:with => /^[a-zA-Z0-9\- ]*$/, :message => "allows only lowercase letters (a-z), uppercase letters (A-Z), numbers (0-9), spaces, and the dash(-)."},
    :if => :not_anonymous?
  validate :username_validate
  validates_date :birthday, :before => lambda { 13.years.ago },
                 :before_message => "is invalid. User must be at least 13 years old to create an account with Soletron",
                 :if => :not_anonymous?

  class << self
    #--
    # overcome cattr_reader issues with decorating
    #++
    def searchable_columns
      [
        'spree_users.email', 'spree_users.username', 'spree_users.current_city',
        'spree_users.about', 'spree_users.favorite_brands'
      ]
    end
    
    # Perform the search.
    def search!(q=nil)
      return([]) if q.nil?
      return(self.all) if q.blank?
      
      conditions, params = [], []
      words = q.split(/[ \t\n\r]/)
      
      searchable_columns.each do |col|
        words.each do |q|
          conditions << "LOWER(#{col}) LIKE ?"
          params << "%#{q.strip.downcase}%"
        end
      end
      
      where(conditions.join(" OR "), *params)
    end
  end

  def username_validate
    down = (self.username ? self.username : '').downcase
    if down.include?("soletron") || down.include?("s0letron") || down.include?("soletr0n") || down.include?("s0letr0n") # FIXME: =~ /s.l.tr.n/ ;-)
      errors.add(:username, "does not allow the word 'Soletron'")
    end
  end

  # Creates an anonymous user.  An anonymous user is basically an auto-generated +User+ account that is created for the customer
  # behind the scenes and its completely transparent to the customer.  All +Orders+ must have a +User+ so this is necessary
  # when adding to the "cart" (which is really an order) and before the customer has a chance to provide an email or to register.
  def self.anonymous!(confirm = true)
    token = Spree::User.generate_token(:persistence_token)
    puts "creating an anonymous user"
    params = { :email => "#{token}@example.net",
               :password => token,
               :password_confirmation => token,
               :persistence_token => token,
               :birthday => DateTime.now - 20.year }
    if confirm
      params[:confirmed_at] = Time.now
    end
    Spree::User.create(params)
  end
  
  def not_anonymous?
    !anonymous?
  end

  # quick patch to modify url displayed
  def to_param
    if username
      "#{id}-#{username}"
    else
      super
    end
  end

  def admin?
    self.has_role? 'admin'
  end

  def merchant?
    self.has_role? 'merchant'
  end
   
  def age
    if birthday
      now = Time.now.utc.to_date
      now.year - birthday.year - ((birthday.month > now.month or (birthday.month == now.month and birthday.day > now.day)) ? 1 : 0)
    end
  end

  def display_name(use_email = false)
    if !self.name.blank?
      self.name
    elsif !self.username.blank?
      self.username
    elsif self.facebook_auth && !self.facebook_auth.nickname.nil? && !self.facebook_auth.nickname.empty?
      self.facebook_auth.nickname
    elsif use_email && !self.email.nil? && !self.email.empty?
      self.email
    else
      ''
    end
  end

  def name_for_facebook
    self.name.blank? ? self.display_name : self.name
  end

  def facebook_auth
    unless @facebook_auth or @facebook_auth == false
      self.user_authentications.each do |user_auth|
        if user_auth.provider == 'facebook'
          @facebook_auth = user_auth
        end
      end
      if !@facebook_auth
        @facebook_auth = false
      end
    end
    @facebook_auth
  end

  def facebook_connected?
    if facebook_auth
      true
    else
      false
    end
  end

  def manage_facebook_pages?
    self.facebook_manage_pages
  end

  # Expecting an array of user_ids
  def user_ids_following_from(users)
    existing_friend_following = Follow.select("following_id").where(:follower_type => 'User', :follower_id => self[:id], :following_type => 'User', :following_id => users)
    existing_friend_following.to_a.inject({}) do |hash, follow|
      hash[follow["following_id"]] = follow
      hash
    end
  end

  def user_ids_followed_by(users)
    existing_friend_followed_by = Follow.select("follower_id").where(:follower_type => 'User', :follower_id => users, :following_type => 'User', :following_id => self[:id])
    existing_friend_followed_by.to_a.inject({}) do |hash, follow|
      hash[follow["follower_id"]] = follow
      hash
    end
  end

  #Expecting an array of taxon_ids
  def store_ids_following_from(taxons)
    existing_like_following = Follow.select("following_id").where(:follower_type => 'User', :follower_id => self[:id], :following_type => 'Store', :following_id => taxons)
    existing_like_following.to_a.inject({}) do |hash, follow|
      hash[follow["following_id"]] = follow
      hash
    end
  end
  
  ###
  # Product search api
  ###

  
  def product_search(type, params={})
    search = case type
    when :favorites
 self.favorited_products.order('favorites.created_at DESC')
     
    when :purchases

      Spree::Product.includes(:variants => {:line_items => :order}).where('spree_orders.user_id=? AND spree_orders.state=?', self, 'complete').order('spree_line_items.created_at DESC')
    when :uploads
      self.uploaded_products.order('spree_products.created_at DESC')
    when :shopping_cart
      # select('spree_products.id')
      Spree::Product.includes(:variants => {:line_items => :order}).where('spree_orders.user_id=? AND spree_orders.completed_at IS NULL', self).order('spree_line_items.created_at DESC')
    end
    
    if search
      if params[:search]
        if params[:search][:brand]
          search = search.includes(:brand).where('brands.name=?', params[:search][:brand])
        end
        if params[:search][:color1]
          search = search.includes(:variants => :option_values, :master => :option_values).where('spree.option_values.name IN (?)', params[:search][:color1])
        end
      end
      
      if type != :uploads and params[:price] and params[:price][:lower] and params[:price][:higher]
        search = search.includes(:master).where("spree_variants.price >= ? AND spree_variants.price <= ?#{ if type != :purchases then ' AND spree_variants.is_master=TRUE' end }", params[:price][:lower], params[:price][:higher])
      end

      search.includes(:images, :master).page(params[:page]).per(params[:per_page] ? params[:per_page] : Spree::Config[:products_per_page])
    end
  end
  
  def generate_username
    if self.username.blank?
      if self.email
        unpart = self.email.split('@')[0].gsub(/[\W^-^ ]/, '').gsub('_', '-')
        my_un = if unpart.size <= 20
          unpart
        else
          unpart[0,20]
        end
        
        if Spree::User.find_by_username(my_un)
          my_un = if my_un.size > 13
            "#{my_un[0,13]}-#{rand(100000)}"
          else
            "#{my_un}-#{rand(100000)}"
          end
        end
        self.username = my_un
      else
        self.username = "sole-#{self.id ? self.id : rand(1000000000)}"
      end
    end
  end

  protected

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    puts "****** user logging in with username: #{login}"
    where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
  end
end
