require 'entity_follow_feeds'

class Store < ActiveRecord::Base
  include EntityFollowFeeds

  has_many    :managers, :class_name => 'StoresUser'
  has_many    :users, :through => :managers, :class_name => 'Spree::User'
  has_many    :line_items, :class_name => 'Spree::LineItem'
  has_many    :shipments, :class_name => 'Spree::Shipment'
  has_one     :taxon, :dependent => :destroy, :class_name => 'Spree::Taxon'
  has_one     :banner_image, :as => :viewable, :dependent => :destroy
  has_many    :feedbacks
  belongs_to  :store_tier
  has_many    :orders_stores
  has_many    :stores_users, :dependent => :destroy
  has_many    :vendor_payment_periods
  
  has_and_belongs_to_many :brands

  after_create :set_username

  attr_accessor :brands_list

  
  scope :latest, order('stores.updated_at DESC')
  scope :oldest, order('stores.updated_at ASC')

  @@searchable_columns = [
    'stores.email', 'stores.username', 'stores.location', 'stores.about',
    'spree_taxons.name', 'spree_users.email' , 'spree_products.name'
  ].freeze
  cattr_reader :searchable_columns
  
  searchable do
    text :username
    text :location
    
    text :taxon
    text :product_types
    text :meta_keywords
    text :meta_description 
    text :brands do
      brands.name
      # brands.products.category
      #       brands.products.subcategory
      #       brands.products.taxons.name
    end
    time :updated_at
  end

  class << self
    # Perform the search on stores.
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

      skope = self.includes(:taxon)
      skope = skope.includes(:stores_users => {:user => []})
      skope = skope.includes(:taxon => {:products => []})
      skope.where(conditions.join(" OR "), *params)
    end
  end

  def to_s
    self.display_name
  end
  
   def featured_products(action=:four)
     return([]) if self.taxon.nil?
     
     if action == :rand
       featured = self.taxon.products.active.all(:conditions => ["featured_image_id != 0"])
       ret_featured = []
       if featured.size > 0
         ret_featured << featured[rand(featured.size)]
       else
         ret_featured << self.taxon.products.active.all(:order => "created_at DESC", :limit => 1)[0]
       end
     elsif action == :four
       featured = self.taxon.products.active.all(:conditions => ["featured_image_id != 0"], :limit => 4)
       if featured.size < 4     # if request is for 4 featured products, and there's fewer than four in the system, supplement with the most recently created
         ret_featured = featured + self.taxon.products.active.all(:order => "created_at DESC", :limit => (4 - featured.size))
         ret_featured.uniq!
       else
         ret_featured = featured
       end
     elsif action == :all
       ret_featured = self.taxon.products.active.all(:conditions => ["featured_image_id != 0"])
     else
       ret_featured = self.taxon.products.active.all(:conditions => ["featured_image_id != 0"], :limit => 4)
     end

     ret_featured
   end

   def hot_products(action=:four)
     if action == :rand
       featured = self.taxon.products.active.all()
       ret_featured = []
       if featured.size > 0
         ret_featured << featured[rand(featured.size)]
       else
         ret_featured << self.taxon.products.active.all(:order => "created_at DESC", :limit => 1)[0]
       end
     elsif action == :four
       featured = self.taxon.products.active.all(:limit => 10)
       if featured.size < 4     # if request is for 4 featured products, and there's fewer than four in the system, supplement with the most recently created
         ret_featured = featured + self.taxon.products.active.all(:order => "created_at DESC", :limit => (4 - featured.size))
         ret_featured.uniq!
       else
         ret_featured = featured
       end
     elsif action == :all
       ret_featured = self.taxon.products.active.all()
     else
       ret_featured = self.taxon.products.active.all(:limit => 4)
     end

     ret_featured
   end



  def name_from_taxon
    if self.taxon.nil?
      "<ERROR> Taxon Missing"
    else
      self.taxon.name
    end
  end
  
  def name
    self.name_from_taxon
  end

  def self.find(*args)
    #puts "**** in store's find method, looking for #{args}"
    s = Store.find_by_username(*args)
    return s unless s.nil?
    #puts "**** fell thru"
    super(*args)
  end

  # quick patch to modify url displayed
  def to_param
    # there was a problem when someone set the username to http://shop.soletron.com/..., so
    # if there is an error with the username, the username will not be rendered in the url
    if username and self.errors['username'].blank?
      "#{username}"
    else
      super
    end
  end
  
  def name
    display_name
  end
  
  def display_name
    self.name_from_taxon || self.username || ''
  end
  
  def name_for_facebook
    self.display_name
  end

  def get_count_featured
    @count_featured = self.featured_products(:all).size
  end

  def brands_list
    brand_names = ""
    self.brands.each do |brand|
      brand_names += (brand.name + ",")
    end
    brand_names[0, brand_names.size-1]
  end

  def add_featured    # BUGBUG(aslepak) - concurrency issue
    get_count_featured
    puts "*** adding a featured item. Current featured count: #{@count_featured}"
    if @count_featured < 0
      @count_featured = 1
      true
    elsif @count_featured < 4
      @count_featured = @count_featured + 1
      true
    else
      false
    end
  end

  def remove_featured
    get_count_featured
    if @count_featured > 0
      @count_featured = @count_featured - 1
    else
      @count_featured = 0
    end
  end
  
  def self.stores_from_facebook_ids(facebook_ids)
    self.where(:facebook_id => facebook_ids)
  end

  def all_order_count
    self.orders_stores.active.count
  end

  def open_order_count
    self.orders_stores.still_open.count
  end

  def past_due_order_count
    self.orders_stores.past_due.count
  end

  def closed_late_order_count
    self.orders_stores.closed_late.count
  end

  def complete_order_count
    self.orders_stores.complete.count
  end

  def canceled_order_count
    self.orders_stores.canceled.count
  end

  def default_order_count
    open_order_count + past_due_order_count
  end

  def get_facebook_auth(user)
    manager = self.managers.find_by_user_id(user)
    return manager.facebook_manager? unless manager.nil?

    if user.has_role?("admin")
      return nil
    else
      raise "Not Authorized for this Store!"
    end
  end

  # Store Name, streetwear, urban clothing, sneakerhead, street style, urban wear, urban apparel, Santonio Holmes
  def get_meta_keywords(include_color, include_defaults)
    name = self.name_from_taxon
    name = "" if name.blank?
    loc = self.location
    loc = "" if location.blank?
    ptypes = self.product_types
    ptypes = "" if ptypes.blank?
    #abt = self.about
    #abt = "" if abt.blank?
    #name + ", " + loc + ", " + ptypes + "," + abt + "," + Spree::Config[:default_meta_keywords]
    name + ", " + loc + ", " + ptypes
  end

  # Soletron, which is owned by Superbowl MVP Santonio Holmes, offers the finest Store Name Products
  # EX: Soletron, which is owned by Superbowl MVP Santonio Holmes, offers the finest TIKKR Products
  def get_meta_description(include_color, include_defaults)
    "Soletron, which is owned by Superbowl MVP Santonio Holmes, offers the finest #{self.name_from_taxon} Products"
  end

  def set_username(param = nil)
    if param.nil?
      param = self.taxon.name unless self.taxon.nil?
    end
    unless param.nil?
      reserved_keywords = ["soletron"]
      action_keywords = ["new", "index"]
      #puts "**** setting username from #{param}"
      try_name = param.to_url
      try_name = "store_link" if try_name.blank?    # have a fallback in case the name the user provides is entirely invalid as a url (e.g. '???')
      if !action_keywords.index(try_name.downcase).nil?
        try_name = try_name + "-1"
      end
      reserved_keywords.each do |word|
        if try_name.downcase.include? word
          try_name = "store_link"
        end
      end
      if !Store.find_by_username(try_name).nil?
        counter = 1
        while !Store.find_by_username("#{try_name}-#{counter}").nil?
          counter += 1
        end
        try_name = "#{try_name}-#{counter}"
      end
      self.username = try_name
      #puts "**** set username to #{self.username}"
      self.save
    end
  end
end
