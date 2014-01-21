Spree::Taxon.class_eval do
  belongs_to :store
  has_one :prototype
  
  has_attached_file :icon,
    :styles => { :mini => '32x32>', :normal => '128x128>' },
    :default_style => :mini,
    :default_url => "/assets/default_taxon.png",
    :path => "assets/taxons/:id/:style/:basename.:extension",
    :storage => 's3',
    :s3_credentials => {
         :access_key_id => S3_CONFIG["access_key_id"] ,
         :secret_access_key => S3_CONFIG["secret_access_key"]
       },
    :bucket => S3_CONFIG["bucket"]

  def featured_product
    child_taxon = self.children[rand(self.children.size)]
    featured = child_taxon.products.active.all(:conditions => ["featured_image_id != 0"])
#    puts "**** selected taxon #{child_taxon.name}"
    if featured.size > 0
      ret_featured = featured[rand(featured.size)]
    else
      ret_featured = child_taxon.products.active.all(:order => "created_at DESC", :limit => 1)[0]
    end
    ret_featured
  end
  
  #TAXONS_WITHOUT_SIZE = ["art", "toys", "electronics", "skateboards", "watches", "sunglasses", "bags", "wallets", "scarves", "sneaker products"]
  def require_size?
    self.prototype.present? && self.prototype.option_types.where("#{Spree::OptionType.quoted_table_name}.name LIKE ?", "%size%").count > 0 || self.parent.present? && self.parent.require_size?
  end

  def active_children
    self.children.where("menu_item IS true")
  end

  # Answers the question, "Does this taxon have another_taxon as one of its parents?"
  def has_parent?(taxon)
    parent_taxon = self.parent
    while parent_taxon.present?
      return true if parent_taxon == taxon
      parent_taxon = parent_taxon.parent
    end
    false
  end

  def display_name
    if self.name == "Miscellaneous"
      "Art, Toys & Electronics"
    else
      self.name
    end
  end

  def has_size?
    if !self.parent.nil?
      with_size = !sizes_hash[self.parent.name].nil? || !sizes_hash[self.name].nil?;
      puts "**** taxon #{self.parent.name} got size #{sizes_hash[self.parent.name]}"
    end
    return with_size
  end

  def sizes_hash
    hash = {"Footwear" => "shoe-size",
            "Tops" => "tops-size",
            "Bottoms" => "bottom-size",
            "Hats" => "hats-size"}
    return hash
  end

  def get_sizes
    size_option_type_name = sizes_hash[self.parent.name]
    if size_option_type_name.nil?
      size_option_type_name = sizes_hash[self.name]    # socks
    end

    return Spree::OptionValue.find_all_by_option_type_id(Spree::OptionType.find_by_name(size_option_type_name).id, :order => 'position')
  end
  
  def get_prototype_id
    prototype = self.prototype || self.parent.prototype
    if prototype.nil?
      prototype = Prototype.find_by_name("Misc")
    end

    return prototype.id
  end

 
  def applicable_filters
    fs = []
    # fs << ProductFilters.taxons_below(self)
    ## unless it's a root taxon? left open for demo purposes

    fs << Spree::ProductFilters.new_price_filter if Spree::ProductFilters.respond_to?(:new_price_filter)
    fs
  end
  
  def commission_percentage
    self.commission_rate || (!self.parent.nil? ? self.parent.commission_percentage : 0)
  end

  class << self
     def departments
       taxonomy = Spree::Taxonomy.find_by_name("Departments")
       where(:taxonomy_id => taxonomy.id )
     end
  end

 def published_products(page)
   self.products.active.where(:state => :published).includes([:images, :master]).page(page).per(Spree::Config[:products_per_page])
 end
end