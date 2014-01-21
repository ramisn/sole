require 'post_to_facebook'

Spree::Product.class_eval do
  include PostToFacebook

  attr_accessor :form
  attr_accessor :product_type
  attr_accessor :product_category
  attr_accessor :product_department

  validates :product_type,
    :presence => true,
    :unless => lambda {|p| p.form.nil? }
  validates :product_department,
    :presence => true,
    :unless => lambda {|p| p.form.nil? }
  validates :description,
    :presence => true
  validates :sale_price,
    :numericality => {
    :greater_than => 0,
    :less_than => Proc.new { |p| p.price.to_i },
    :if => Proc.new { |p| p.sale_price.to_i > 0 }
  }
  validates :brand_id,
    :presence => true,
    :unless => lambda { |p| p.is_a?(UserProduct) }

  validate :validate_sale_at
  
  class_variable_set(:@@exempt_product_types, %w{Art Toys Skateboards})
  cattr_reader :exempt_product_types

  # Ensure that product category is required.
  #
  # Please note that we do not validate product category if there is no
  # product type or product type does not have any product categories.
  validate do
    return true if self.form.nil?
    return true if self.product_type.nil?
    return true if self.exempt_product_types.include?(self.product_type.name)
    
    if self.product_category.blank?
      errors.add(:product_category, "can't be blank")
    end
    
    true
  end
  
  validate do
    return true if self.master.price.blank?
    
    unless self.master.price_before_type_cast.to_s =~ /^[0-9\.\,]+$/
      errors.add(:price, 'is invalid')
      
      # Do not show an incorrect price scoped to BigDecimal.
      self.price = nil
    end
    
    true
  end

  has_many :products, :conditions => "#{Spree::Product.quoted_table_name}.deleted_at IS NULL"
  belongs_to :product

  #--
  # FIXME
  #
  # irb(main):001:0> Product.last.line_items
  # ActiveRecord::StatementInvalid: Mysql2::Error: Unknown column 'line_items.product_id' in 'where clause': SELECT `line_items`.* FROM `line_items` WHERE ((`line_items`.`product_id` = 1060501745))
  #++
  has_many :line_items
  has_many :correct_line_items,
    :source => :line_items,
    :through => :variants
  has_many :favorites

  delegate_belongs_to :master, :sale_price
  delegate_belongs_to :master, :sale_start_at
  delegate_belongs_to :master, :sale_end_at

  has_one :feed_item, :as => :feedable
  belongs_to :brand

  has_many :color1_option_types,
    :through => :product_option_types,
    :class_name => "OptionType",
    :foreign_key => "product_id",
    :source => :option_type,
    :conditions => ["spree_option_types.presentation = ?", 'color1']
  
  has_many :promotions

  after_initialize :default_values

  # default Spree active scope is not_deleted.available
  scope :active, Proc.new { not_deleted.available.viewable }

  scope :viewable, where("spree_products.state = ?", 'published')
  scope :newly_added, Proc.new {
    where("spree_products.created_at > ? OR spree_products.updated_at > ?", 1.week.ago, 1.week.ago).order("spree_products.updated_at DESC")
  }
  scope :roots, where("spree_products.product_id IS NULL")
  scope :with_image, joins(:images).group("spree_products.id")
  scope :presentable, lambda { active().with_image() }
  scope :randomize, lambda { order("RAND()") }
  scope :with_featured_image, where("spree_products.featured_image_id > 0")
  scope :without_featured_image,
    where("spree_products.featured_image_id IS NULL OR spree_products.featured_image_id <= 0")

  scope :branded, lambda { |brand|
    joins(:brand).where("brands.name = ?", brand)
  }
  
  scope :rating, order('spree_products.rating DESC')
  scope :sale, Proc.new {
    joins(:master).where('(spree_variants.sale_price > 0 AND spree_variants.sale_start_at IS NULL AND spree_variants.sale_end_at IS NULL) OR (spree_variants.sale_price > 0 AND spree_variants.sale_start_at <= NOW() AND spree_variants.sale_end_at >= NOW())')
  }

  def tags
    return []
  end
  
  # Return true if product is on sale.
  def sale?
    return false if self.sale_price.nil?
    return false if self.sale_price.zero?
    return true unless self.sale_at?

    self.sale_start_at <= Time.now && self.sale_end_at >= Time.now
  end
  
  # Return true if product has sale_at.
  def sale_at?
    [self.sale_start_at, self.sale_end_at].compact.any?
  end
  
  # Return sale discount.
  def sale_discount
    return 0 if self.sale_price.nil?
    
    self.sale_price / self.price
  end
  
  # duplicates get_product_category_taxon - investigate (aslepak)
  def category_taxon
    @category_taxon ||= self.taxons.find_by_taxonomy_id(Spree::Taxonomy.find_by_name('Categories'))
  end

  def variant_images
    Spree::Image.find_by_sql("SELECT spree_assets.* FROM spree_assets LEFT JOIN spree_variants ON (spree_variants.id = spree_assets.viewable_id) WHERE (spree_variants.product_id = #{self.id})")
  end

  # for the comments controller
  def feed_items
    feed_item
  end

  def store
    store_taxons = self.taxons.where("spree_taxons.store_id IS NOT NULL")
    if store_taxons.first
      store_taxons.first.store
    end
  end
  
  def orders
    correct_line_items.map{|li| li.order}
  end
  
  def uniform_price
    self.sale? ? self.sale_price : self.price
  end

  def is_favorite_of?(user)
    return true if user.favorited_products.find_by_id(self.id) 
    return false
  end
  
  ###
  # This state machine could be hooked into the finish button on product additions and set the
  # product to being published.
  ###
  state_machine :state, :initial => :draft do
    event :add_skus do
      transition :draft => :has_skus
    end
    event :publish do
      transition :has_skus => :published
    end
  end
  
  def send_email_to_followers
    products = Product.find(:all, :conditions => ["created_at >= ?",Date.today.strftime("%Y-%m-%d").to_s])
    stores = []
    products.each do|prod|
      unless prod.blank?
        stores << prod.store
      end
    end
    stores = stores.uniq
    stores.each do |store|      
      followers = store.followers
      products = store.taxon.products.all :conditions => ["created_at >= ?",Date.today.strftime("%Y-%m-%d").to_s]      
      unless products.blank?
        UserMailer.items_creation_notifications(followers,products,store.username)
      end
    end
  end
  
  def update_on_less_items
    products = Product.find(:all, :conditions => ["count_on_hand <= 3"])
    stores = []
    products.each do|prod|
      unless prod.blank?
        stores << prod.store
      end
    end
    stores = stores.uniq
    stores.each do |store|
      unless store.blank?
        products = store.taxon.products.all :conditions => ["count_on_hand <= 3"]      
        unless products.blank?
          UserMailer.update_on_less_items(store.email,products,store.username)
        end
      end
    end    
  end

  def featured?
    !self.root_product.featured_image_id.nil? && self.root_product.featured_image_id != -1
  end

  def find_image_to_feature
    product = self.root_product
    product.get_siblings.each do |child_product|
      if child_product.images.empty?
        next
      else
        child_product.images[0].featured = true
        child_product.images[0].save

        product.featured_image_id = child_product.images[0].id
        break
      end
    end
  end

  def has_more_colors?
    get_siblings
    logger.info "**** siblings: #{@siblings}"
    return !@siblings.nil? && @siblings.count > 1   # return true if there's more than one
  end

  def get_siblings
    return @siblings if @siblings.present?
    if self.product_id.nil?    #then this is the parent product
      products = Array.new(self.products)
      products.insert(0, self)
    else
      products = Array.new(self.product.products)
      products.insert(0, self.product)
    end
    @siblings = products
  end

  def colors_hash
    color_options = Spree::OptionType.find_all_by_name(["color1", "color2"])
    product_colors = {}
    product_colors[:primary] = product_colors[:secondary] = nil
    if (!variants.nil? && variants.count > 0)
      variant = variants[0]
      option_value = variant.option_values.find_by_option_type_id(color_options[0])
      product_colors[:primary] = option_value unless option_value.nil?

      option_value = variant.option_values.find_by_option_type_id(color_options[1])
      product_colors[:secondary] = option_value unless option_value.nil?
    end

    return product_colors
  end

  def colors
    product_colors = colors_hash
    colors_string = product_colors[:primary].presentation unless (product_colors.nil? || product_colors[:primary].blank?)
    if !product_colors[:secondary].nil? and product_colors[:secondary].name != "colornone"
      colors_string += "/" + product_colors[:secondary].presentation
    end

    return colors_string
  end

  def store_taxon
    return @store if @store.present?
    if !self.taxons.nil?
      @store = self.taxons.find_by_taxonomy_id(Spree::Taxonomy.find_by_name("Stores").id)
    end
  end

  def store_name
    if !store_taxon.nil?
      store_taxon.name
    else
      ""
    end
  end
  
  def commission_percentage
    self.category_taxon.commission_percentage
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
    if current_user
      manager = self.store.managers.find_by_user_id(current_user)
      if manager.nil?
        unless current_user.admin?
          logger.error "***** unathorized access by user #{current_user.id}"
        end
        nil
      else
        manager.facebook_access_token
      end
    else
      self.store.managers[0].facebook_access_token
    end
  end

  def facebook_poster_id(options={})
    self.store.facebook_id
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

    "#{self.store_taxon.name} has just added #{facebook_product_to_name(options).name}#{more_message} to their store on Soletron"
  end

  def facebook_link(options={})
    facebook_domain_posted_from + main_app.store_path(self.store)#product_path(facebook_product_to_name(options))
  end

  def facebook_picture_to_use(options={})
    facebook_product_to_name(options).images.empty? ? facebook_domain_posted_from+"/assets/noimage/product.jpg" : facebook_product_to_name(options).images.first.attachment.url(:product)
  end

  def facebook_description(options={})
    facebook_product_to_name(options).description
  end

  def root_product
    self.product.nil? ? self : self.product
  end

  def primary_color
    get_color("color1")
  end

  def secondary_color
    get_color("color2")
  end

  def get_variant_sku
    if (!self.variants.nil? && self.variants.size > 0)
      self.variants[0].sku
    else
      ""
    end
  end

  def remove_siblings_and_variants!
    self.products.update_all "deleted_at" => Time.now if !self.products.nil?
    self.variants.update_all "deleted_at" => Time.now if !self.variants.nil?
  end

  def get_category
    taxon = self.get_product_category_taxon
    return "" if taxon.nil?
    if taxon.parent == Spree::Taxon.find_by_name("Miscellaneous")
      return ""
    else
      return taxon.name
    end
  end

  def get_sex(string=false)
    women = false
    men = false

    dept_taxons = self.taxons.find_all_by_taxonomy_id(Spree::Taxonomy.find_by_name("Departments").id)
    sex = :mens    # default, in case the Dept taxon is missing
    if !dept_taxons.blank?
      dept_taxons.each do |t|
        sex = :childrens if  t.name == I18n.t(:childrens)
        women = true if  t.name == I18n.t(:womens)
        men = true if  t.name == I18n.t(:mens)
      end
    end

    if men and women
      sex = :unisex
    elsif women
      sex = :womens
    end

    if string
      return I18n.t(sex)
    else
      return sex
    end
  end

  def get_sex_s
    return get_sex(true)
  end

  def get_type
    taxon = self.get_product_category_taxon
    return "" if (taxon.nil? || taxon.parent.nil?)
    if taxon.parent == Spree::Taxon.find_by_name("Miscellaneous")
      return taxon.name   # Art and Toys
    else
      return taxon.parent.name
    end
  end

  # duplicates category_taxon - investigate! (aslepak)
  def get_product_category_taxon
    self.taxons.find_by_taxonomy_id(Spree::Taxonomy.find_by_name("Categories").id)
  end

  def brand_name
    return self.root_product.brand.nil? ? "" : self.root_product.brand.name
  end

  # Brand Product Category, Brand Product Title, Sex Brand Product Category
  # Ex: TIKKR Watches, TIKKR White Collar Watch, Men's TIKKR Watches,
  def get_meta_keywords(include_color = false, include_defaults = false)
    return "" if self.new_record?
    if include_color
      product_name = self.accurate_title
      product_name = self.accurate_title_for_colors
    else
      product_name = self.name.nil? ? "" : self.name
    end
    cat_taxon = self.get_product_category_taxon
    category_name = cat_taxon.nil? ? "" : cat_taxon.name
    meta_data = product_name + ", " + category_name + ", " + self.brand_name
    meta_data += ", " + self.meta_keywords if self.meta_keywords.present?

    meta_data += ", " + self.brand_name + " " + category_name + ", " + self.brand_name + " " + product_name + ", " +
      self.get_sex_s + " " + self.brand_name + " " + category_name

    if include_defaults
      meta_data = meta_data + ", " + Spree::Config[:default_meta_keywords]
    end

    return meta_data.gsub(/\s+/, " ").strip
  end

  # Product Name by Brand at Soletron.com
  # Ex: White collar Watch by TIKKR at Soletron.com
  def get_meta_description(include_color = true, include_defaults = false)
    return "" if self.new_record?
    if include_color
      product_name = self.accurate_title
      product_name = self.accurate_title_for_colors
    else
      product_name = self.name.nil? ? "" : self.name
    end

    cat_taxon = self.get_product_category_taxon
    cat_name = cat_taxon.nil? ? "" : cat_taxon.name
    meta_description = self.meta_description.to_s
    meta_description += product_name + " " + cat_name + " by " + self.brand_name + " at Soletron.com"

    meta_description += ", " + Spree::Config[:default_meta_keywords] if include_defaults

    return meta_description.gsub(/\s+/, " ").strip
  end

  def accurate_title
    color_options = Spree::OptionType.find_all_by_name(["color1", "color2"])
    color = ""
    name = self[:name]
    if (!self.variants.blank?)
      variant = self.variants[0]
      color_options.each do |option_type|
        option_value = variant.option_values.find_by_option_type_id(option_type.id)
        if !option_value.nil? && option_value.name != "colornone"
          color += (option_value.presentation + "/")
        end
      end

      if !color.empty? && !name.nil?
        name += (" " + color[0, color.length-1])
      end
    end
    name
  end
  
  def accurate_title_for_colors
    color_options = Spree::OptionType.find_all_by_name(["color1", "color2"])
    color = ""
    name = self[:name]
    if (!self.variants.blank?)
      variant = self.variants[0]
      color_options.each do |option_type|
        option_value = variant.option_values.find_by_option_type_id(option_type.id)
        if !option_value.nil? && option_value.name != "colornone"
          color += (option_value.presentation + "/")
        end
      end

      if !color.empty? && !name.nil?
        name += (" - " + color[0, color.length-1])
      end
    end
    name
  end

  def has_size?
    self.has_variants? ? !self.variants[0].option_values.where("name LIKE 'size%'").empty? : false   
  end

  def get_attribute_value
    property = Property.find_by_name(:attribute)
    product_properties = ProductProperty.includes(:property).where("product_id = #{self.id} and property_id = #{property.id}")
    if !product_properties.nil? && !product_properties.empty?
      product_properties[0].value
    else
      ""
    end
  end

  def department
    taxon_mens = self.taxons.find_by_name("Men's")
    taxon_womens = self.taxons.find_by_name("Women's")
    taxon_childrens = self.taxons.find_by_name("Children's")

    dept = ""
    if !taxon_mens.nil? && !taxon_womens.nil?
      dept = "Unisex"
    elsif !taxon_mens.nil?
      dept = "Men's"
    elsif !taxon_womens.nil?
      dept = "Women's"
    elsif !taxon_childrens.nil?
      dept = "Children's"
    end

    return dept
  end
  
  def formatted_department
    self.department.gsub("'", '').downcase
  end

  def require_size?
    self.taxons.present? && self.taxons.find{|t| t.require_size?}.present?
  end

  class_variable_set(:@@taxon_names, %w{Tops Hats Accessories Footwear Miscellaneous Bottoms})
  cattr_reader :taxon_names
  
  class << self
    # Return random per_page products from each product type.
    #--
    # FIXME: taxon_names should not be hard-coded
    # FIXME: we should use RAND() once we have staging; pgsql uses RANDOM()
    #++
    def random_marketplace(n=nil)
      per_page = n || Spree::Config[:products_per_page]
      taxons = taxon_names.map {|name| Spree::Taxon.find_by_name(name)}.compact
      products = []
      
      ###
      # From Justin: I needed to patch this for the tests, since we aren't guaranteed to have at least 48 products.
      ###
      last_products_size = products.size
      while products.size < per_page
        puts "inside the loop and at size #{products.size}"
        taxons.each do |taxon|
          products << Spree::Product.presentable.randomize.limit(8).in_taxon(taxon)
          products.flatten!
          products.uniq!
        end
        ###
        # From Justin: If there are no more new products found after going through all the taxons
        # Then it just breaks out of the while loop. A test has to be conducted or this will go
        # through an infinite loop when there aren't at least 48 products in the database.
        # If you want to have this have to fail 3 or 4 times, before it breaks, then just create a
        # a counter that counts how many times last_products_size == products.size and when the
        # counter fills up, then break out of the while loop.
        ###
        if last_products_size == products.size
          break
        else
          last_products_size = products.size
        end
      end

      products.sort_by { rand }.first(per_page)
    end
    
    # Return random products for each of product types.
    def random_products_by_product_type(n=8)
      skope = presentable.randomize.limit(n)
      
      (ActiveSupport::OrderedHash.new).tap do |hasz|
        taxon_names.each do |taxon_name|
          taxon = Spree::Taxon.find_by_name(taxon_name)
          hasz[taxon] = skope.in_taxon(taxon) unless taxon.nil?
        end
      end
    end
    
    def apply_filters(params, taxon=nil, results=nil)
      results ||= taxon.nil? ? nil : Spree::Product.active.in_taxon(taxon)
      
      params.each do |key, value|
        next if value.blank?
        case key
        when "product_group_query"
          query = Hash[*params[:product_group_query].split('/')].symbolize_keys
          results = Spree::Product.add_to_results_collection(results, Spree::Product.active.branded(query[:branded]))
        when "branded"
          unless params.key?("product_group_query")   # let the params that are part of the URL take precedence
            results = Spree::Product.add_to_results_collection(results, Spree::Product.active.branded(value))
          end
        when "color1", "size"
          value_products = []
          value.split(",").each do |val|
            puts "*** found option value #{val}"
            value_products += Spree::Product.active.with(val)
            puts "*** got #{Spree::Product.active.with(val).size} results"
          end
          puts "**** total results: #{value_products.size}"
          results = Spree::Product.add_to_results_collection(results, value_products)
        when "sex"
          value_products = []
          value.split(",").each do |val|
            puts "*** found dept value #{val}"
            taxon = case val
            when "mens"
              Spree::Taxon.find_by_name("Men's")
            when "womens"
              Spree::Taxon.find_by_name("Women's")
            when "childrens"
              Spree::Taxon.find_by_name("Children's")
            end
            puts "**** got a taxon: #{taxon.name}"
            value_products += Spree::Product.active.in_taxon(taxon)
            puts "*** got #{Spree::Product.active.in_taxon(taxon).size} results"
          end
          puts "**** total results: #{value_products.size}"
          results = Spree::Product.add_to_results_collection(results, value_products)
        when "price_between"
          # weird... 1000 does not get parsed correctly here.
          first = value.split(",")[0].to_i
          second = value.split(",")[1].to_i
          if first > second
            low = second
            high = first
          else
            low = first
            high = second
          end
          puts "**** low is #{low} and high is #{high}"
          results = Spree::Product.add_to_results_collection(results, Spree::Product.active.price_between(low, high))
        end
      end

      results || Spree::Product.active
    end
    
    def add_to_results_collection(results, products)
      if results.nil?
        results = products.to_a
      else
        results &= products.to_a
      end
      return results
    end

    def check_newly_added
      new_taxon = Spree::Taxon.find_by_name(DEPT_TAXONS[:newly_added])
      if new_taxon.nil?
        logger.error "Couldn't find the #{DEPT_TAXONS[:newly_added]} taxon - has it been renamed?"
      else
        self.in_taxon(new_taxon).each do |product|
          if product.updated_at.to_date < (DateTime.now - Spree::Config[:newly_added_period_days].days).to_date
            product.taxons.delete(new_taxon)
          end
        end
      end
    end
  end

  class << self
    # Calculate rating for all products.
    def calculate_rating!
      find_each(:batch_size => 5) do |product|
        product.transaction do
          product.lock!
          product.calculate_rating! if product.calculate_rating?
        end
      end

      true
    end
    
    # Compare two products by revelance.
    #
    # In this context, revelance means whether words in a query are included
    # in the product names.
    def compare_by_revelance(query, product1, product2)
      return 0 if query.blank?
      
      words = query.split(/[ \t\n\r]/)
      
      name1 = product1.name.split(/[ \t\n\r]/)
      hits1 = words.select {|word| name1.include?(word)}
      
      name2 = product2.name.split(/[ \t\n\r]/)
      hits2 = words.select {|word| name2.include?(word)}
      
      hits1.size <=> hits2.size
    end
    
    def compare_by_following(current_user, product1, product2)
      return 0 if current_user.nil?
      
      store1 = product1.store
      store2 = product2.store
      
      followed1 = store1.nil? ? false : current_user.is_following?(store1)
      followed2 = store2.nil? ? false : current_user.is_following?(store2)
      
      followed1 = (followed1 == true) ? 1 : 0
      followed2 = (followed1 == true) ? 1 : 0
      
      followed1 <=> followed2
    end
  end
  
  # The weights are used to multiply each type of data points.
  class_variable_set(:@@properties_rating_weight, {
    :followers  => 1,
    :page_views => 2,
    :favorites  => 3,
    :orders     => 4
  }.freeze)
  cattr_reader :properties_rating_weight

  # The weight is used as the maximum weight for freshness, that is now.
  class_variable_set(:@@now_rating_weight, 100)
  cattr_reader :now_rating_weight
  
  class_variable_set(:@@rating_time_scale, 1.hour.to_i)
  cattr_reader :rating_time_scale
  
  # The maximum number of hours taken into account when rating for freshness.
  class_variable_set(:@@rating_time_max, 1.month.to_i / self.rating_time_scale)
  cattr_reader :rating_hours_horizon
  
  # Return true if the rating should be recalculated.
  def calculate_rating?
    return true if self.rated_at.nil?
    
    self.rated_at <= [ rand(12), 1 ].max.hours.ago # do not kill the db
  end
  
  # Calculate rating.
  #
  # The rating is calculated using the following requirements:
  #
  #   1. orders,
  #   2. times favorited,
  #   3. page views,
  #   4. seller's followers.
  #
  def calculate_rating!
    now = Time.now.to_i
    
    sums = []
    
    properties = {}
    properties[:followers]  = self.store.followers.map(&:created_at) unless store.nil?
    properties[:favorites]  = self.favorites.map(&:created_at)
    properties[:orders]     = self.orders.map(&:created_at)
    properties.each do |k, v|
      weight = self.properties_rating_weight[k]
      raise(ArgumentError) unless v.is_a?(Array)
      raise(ArgumentError) if weight.nil?
      
      timed = properties[k].map do |created_at|
        # (difference in hours / 1 month) * maximum weight for freshness
        distance = [ now - created_at.to_i, 1 ].max
        quotient = distance / self.rating_time_scale
        quotient * self.now_rating_weight
      end
      
      # (sum of freshness points) * weight for a given property
      sums << timed.sum * weight
    end

    self.update_attribute(:rated_at, Time.now)
    self.update_attribute(:rating, sums.sum)
    true
  end

  # Return featured products related to a given product.
  def featured(n = 4)
    return(Spree::Product.random_marketplace(n)) if self.store.nil?
    return(Spree::Product.random_marketplace(n)) if self.store.taxon.nil?
    ret = []
    ret.concat(self.store.taxon.products.presentable.with_featured_image.randomize)
    ret.concat(self.store.taxon.products.presentable.without_featured_image.randomize)
    ret.concat(Spree::Product.random_marketplace(n))
    ret.delete(self)
    ret.uniq!
    ret.first(n)
  end
  
  # Return suggested products related to a given product.
  def suggested(n = 4)
    # TODO : Commented out because this request is extremely slow and makes page render twice.
    # return(Spree::Product.random_marketplace(n)) if self.get_type.nil?
    # 
    # kolors = self.colors_hash
    # color1, color2 = kolors[:primary], kolors[:secondary]
    # 
    # ret = []
    # ret.concat(color1.products.presentable.randomize.limit(n * 5)) unless color1.nil?
    # ret.concat(color2.products.presentable.randomize.limit(n * 5)) unless color2.nil?
    # ret = ret.sort_by { rand }
    # ret.concat(Spree::Product.random_marketplace(n))
    # ret.reject! {|product| product.get_type == self.get_type }
    # ret.delete(self)
    # ret.uniq!
    # ret.first(n)
    
    Spree::Product.active.with_image.randomize.limit(n)
  end
  
  protected
  # Ensure that sale_start_at lt sale_end_at.
  def validate_sale_at
    return true if self.sale_start_at.nil?
    return true if self.sale_end_at.nil?
      
    if self.sale_start_at >= self.sale_end_at
      errors.add(:sale_start_at, 'must be before sale end')
    end
      
    true
  end

  def get_color(color_name)
    if (!self.variants.nil? && !self.variants.empty?)
      get_color_options

      option_value = self.variants[0].option_values.find_by_option_type_id(@color_options[color_name])
      return option_value.nil? ? nil : option_value.id
    end
  end

  def get_color_options
    return @color_options if @color_options.present?

    @color_options = Hash.new
    color_options = Spree::OptionType.find_all_by_name(["color1", "color2"])
    color_options.each do |option|
      @color_options.merge!( { option.name => option.id })
    end
    @color_options
  end

  private

  def default_values
    self.available_on ||= Time.now.year.to_s + "/" + Time.now.month.to_s + "/" + Time.now.day.to_s
    true
  end

end

# 31Break
# ::Scopes::Product.module_eval do
#   Product::SCOPES[:status] = {
#     :active => nil,
#     :newly_added => nil,
#   }
# end
