Spree::Product.class_eval do
  searchable do
    # Boost up the name in the results
    text :name, :boost => 2.0
    text :description
    text :first_variant_sku
    text :category
    text :subcategory
    text :meta_keywords
    time :available_on

    string :product_name, :stored => true do
      name.downcase.sub(/^(an?|the)\W+/, '')
    end


    boolean :is_active, :using => :is_active?
    boolean :on_sale, :using => :sale?

    float   :price
    float   :price_for_slider

    integer :sold_count
    integer :page_views_count
    integer :favorites_count

    integer :taxon_ids, :multiple => true, :references => Spree::Taxon

    integer :taxon, :multiple => true do
      (self.taxons + self.taxons.map(&:parent)).delete_if {|item| item.nil? }.uniq.map(&:id) if self.taxons.count > 0
    end


    string :brand_name

    string :taxon_name, :multiple => true do
      taxons.map(&:name)
    end


    string "color_facet", :multiple => true do
      colors = self.get_option_values('color1') +  self.get_option_values('color2')
      colors = colors.map {|color| color[:presentation].downcase }
      colors.reject {|n| n == 'none'}
      colors
    end


    string "size_facet", :multiple => true do
      self.sizes.map(&:presentation)
    end

    string "brand_facet", :multiple => true do
      brand_name
    end

    string "department_facet" do
      formatted_department
    end

    if respond_to?(:stores)
      integer :store_ids, :multiple => true, :references => Store
    end

  end

  def sizes
    size_types = ["hats-size", "tops-size", "bottom-size", "shoe-size", "sock-size"]
    size_types.map{|size| self.get_option_values(size)}.flatten

  end

  def self.sizes
    size_types = ["hats-size", "tops-size", "bottom-size", "shoe-size", "sock-size"]
    size_types.inject([]) do |arr, size_type|
      arr += Spree::OptionType.where(:name => size_type).first.option_values.order(:position)
    end
  end

  def self.departments
    size_types = ["hats-size", "tops-size", "bottom-size", "shoe-size", "sock-size"]
    size_types.inject([]) do |arr, size_type|
      arr += Spree::OptionType.where(:name => size_type).first.option_values.order(:position)
    end
  end

  def brand_name
    self.brand.nil? ? '' : self.brand.name
  end

  def sold_count
    ids = self.variants.map(&:id)
    ids << self.master.id if self.master.present? && self.master.id.present?
    ids.present? ? Spree::LineItem.joins(:order).where("variant_id IN (#{ids.join(", ")})").sum(:quantity) : 0
  end

  def page_views_count
    self.page_views
  end

  def favorites_count
    self.favorites.count
  end

  def is_active?
    !deleted_at && available_on &&
    (available_on <= Time.zone.now) &&
    (Spree::Config[:allow_backorders] || count_on_hand > 0)
  end

  def get_product_property(prop)
    #p = Property.find_by_name(prop)
    #ProductProperty.find(:product_id => self.id, :property_id => p.id)
    pp = Spree::ProductProperty.first(:joins => :property, :conditions => {:product_id => self.id, :properties => {:name => prop.to_s}})
    pp.value if pp
  end


  def category
    self.taxons.detect{|taxon| taxon.taxonomy.name == "Categories"}.try(:parent).try(:name)
  end

  def subcategory
    self.taxons.detect{|taxon| taxon.taxonomy.name == "Categories"}.try(:name)
  end

  def first_variant_sku
    self.variants[0].sku if self.variants.first.present?
  end

  def price_for_slider
    self.price.to_f
  end
  
  # private

  def price_range
    max = 0
    Spree::Search::SpreeSunspot.configuration.price_ranges.each do |range, name|
      return name if range.include?(price)
      max = range.max if range.max > max
    end
    I18n.t(:price_and_above, :price => max)
  end
  
  
  def get_option_values(option_name)
    sql = <<-eos
    SELECT DISTINCT ov.id, ov.presentation
    FROM spree_option_values AS ov
    LEFT JOIN spree_option_types AS ot ON (ov.option_type_id = ot.id)
    LEFT JOIN spree_option_values_variants AS ovv ON (ovv.option_value_id = ov.id)
    LEFT JOIN spree_variants AS v ON (ovv.variant_id = v.id)
    LEFT JOIN spree_products AS p ON (v.product_id = p.id)
    WHERE (ot.name = '#{option_name.gsub('_', '-')}' AND p.id = #{self.id});
    eos
    Spree::OptionValue.find_by_sql(sql)
  end


end
