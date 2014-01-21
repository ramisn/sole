Spree::Admin::ProductsController.class_eval do
  before_filter :load_store
  before_filter :load_taxons
  before_filter :set_fullsize, :only => :index
  before_filter :init
  before_filter :set_fullsize
  create.before :create_before
  #update.before :update_before
  
  def init
    @selected = { "product_type" => 0, "product_category" => 0 }
    @editing = false
    @cat_index = 0
    @form_name = "new_product"
  end

  def destroy
    @product = Product.find_by_permalink(params[:id]).root_product
    saved = true
    puts "***** found a product to delete: #{@product.permalink}"
    
    @product.get_siblings.each do |product|
      product.deleted_at = Time.now()

      product.variants.each do |v|
        v.deleted_at = Time.now()
        v.save
      end

      saved &= product.save
    end

    if saved
      flash.notice = I18n.t("notice_messages.product_deleted")
    else
      flash.notice = I18n.t("notice_messages.product_not_deleted")
    end

    respond_with(@product) do |format|
      format.html { redirect_to collection_url }
      format.js  { render_js_for_destroy }
    end
  end

  def feature
    ret = true
    if @product.featured_image_id.nil?
      if @product.state == "published" && @store.add_featured
        puts "**** Featuring product #{@product.permalink}"
        @product.get_siblings.each do |product|
          if product.images.empty?
            next
          else
            @product.root_product.taxons << Spree::Taxon.find_by_name("Featured")

            product.images[0].featured = true
            product.images[0].save
            @product.root_product.featured_image_id = product.images[0].id
            @product.root_product.save
            break
          end
        end
        if @product.root_product.featured_image_id.nil?
          @store.remove_featured    # concurrency issue if merch 1 tries to take last featured spot with a product w/no images, while merch 2 tries to take it w/valid product
          ret = false
        end
      else
        ret = false
      end
    else
      puts "**** Un-Featuring product #{@product.permalink}"
      if !@product.featured_image_id.nil?
        img = Spree::Image.find(@product.featured_image_id)
        img.featured = false
        img.save
      end
      @product.root_product.taxons.delete Spree::Taxon.find_by_name("Featured")
      @product.featured_image_id = nil
      @product.save
    end

    if ret
      return ret
    else
      raise "An Error has occurred"
    end
  end
  
  def preview
    @product = Spree::Product.new(params[:product])
    create_before
    if @product.valid?
      if request.xhr?
        render :nothing => true
      else
        @action = :preview
        render :template => "spree/products/show"
      end
    else
      if request.xhr?
        render :text => @product.errors.full_messages.join(", "), :status => 422
      else
        render :action => :new
      end
    end
  end

  def publish
    @product.category_taxon.menu_item = true    # once an item has been published for this taxon, it automatically becomes visible in the menu system
    @product.category_taxon.save

    @product.get_siblings.each do |product|
      product.publish unless product.published?
    end

#    if @product.featured? && !params[:featured].nil? && params[:featured] != ""
    if !params[:featured].nil? && !params[:featured].empty?
      if @product.featured? || @product.root_product.featured_image_id == -1
        if @product.root_product.featured_image_id != -1
          # un-feature the previous featured image
          img = Spree::Image.find(@product.root_product.featured_image_id)
          img.featured = false;
          img.save
        end
        @product.root_product.featured_image_id = nil
      end

      # set the new featured image
      img = Spree::Image.find_by_id(params[:featured].to_i)
      unless img.nil?
        puts "**** finding featured image: #{img.alt}"
        img.featured = true
        img.save

        # update the featured image id on the product
        @product.featured_image_id = img.id
      end
      @product.save
    else
      @product.featured_image_id = nil
      @product.find_image_to_feature
      @product.save
    end
    redirect_to merchant_store_url(@store)
  end

  def collection
    
    return @collection if @collection.present?

    unless request.xhr?
      params[:search] ||= {}
      # Note: the MetaSearch scopes are on/off switches, so we need to select "not_deleted" explicitly if the switch is off
      if params[:search][:deleted_at_is_null].nil?
        params[:search][:deleted_at_is_null] = "1"
      end

      # display only 'parent' products
      params[:search][:product_id_is_null] = "1"
      unless params[:store_id].blank? && current_user.has_role?(:admin)
        params[:search][:taxons_id_equals] = Store.find(params[:store_id]).taxon.id
      end

      params[:search][:meta_sort] ||= "name.asc"
      @search = super.metasearch(params[:search])

      @collection = @search.relation.group_by_products_id.includes({:variants => [:images, :option_values]}).page(params[:page]).per(Spree::Config[:admin_products_per_page])
    else
      includes = [{:variants => [:images,  {:option_values => :option_type}]}, :master, :images]

      @collection = super.where(["name #{LIKE} ?", "%#{params[:q]}%"])
      @collection = @collection.includes(includes).limit(params[:limit] || 10)

      tmp = super.where(["variants.sku #{LIKE} ?", "%#{params[:q]}%"])
      tmp = tmp.includes(:variants_including_master).limit(params[:limit] || 10)
      @collection.concat(tmp)

      @collection.uniq
    end
  end

  def load_taxons
    if !@product_type.present?
      # BUGBUG (aslepak) rewrite to make this into just one query!
      clothing_id = Spree::Taxon.find_by_name("Clothing").id
      @product_type = Spree::Taxon.where(:parent_id => clothing_id) + Spree::Taxon.where(:name => "Miscellaneous") + Spree::Taxon.find_all_by_name("Accessories") + Spree::Taxon.find_all_by_name("Footwear")
    end

    if !@product_category.present?
      @product_category = []
      @product_type.each do |category|
        @product_category << category
      end
    end

    if !@brands.present?
      @brands = @store.nil? ? nil : @store.brands
    end

    if !@departments.present?
      @departments = []
      @departments[0] = {:id => 0, :name => "Men's"}
      @departments[1] = {:id => 1, :name => "Women's"}
      @departments[2] = {:id => 2, :name => "Unisex"}
      @departments[3] = {:id => 3, :name => "Children's"}
    end

    @miscPrototypeId = Spree::Prototype.find_by_name("Misc").id
  end

  def create_before
    @product.form = true
    
    set_prototype(params[:taxon])

    Rails.logger.info "**** available on: #{params[:product][:available_on]}"

    Rails.logger.info "**** category:" + params[:taxon][:product_category_id].to_s
    # for things that have a category, find the category taxon, else just use the product type taxon
    if !params[:taxon][:product_category_id].nil? && !params[:taxon][:product_category_id].empty?
      taxon = Spree::Taxon.find_by_id(params[:taxon][:product_category_id])
    else
      taxon = Spree::Taxon.find_by_id(params[:taxon][:product_type_id])
    end
    @product.taxons << taxon unless taxon.nil?
    if params[:custom] == "true"
      taxon = Spree::Taxon.find_by_id("departments/custom_products")
      @product.taxons << taxon unless taxon.nil?
    end
    @product.brand = Brand.find_by_id(params[:taxon][:brand_id].to_i)

    params[:attachments].each do |attachment|
      image = Spree::Image.new(:attachment => attachment)
      @product.images << image
    end unless params[:attachments].blank?

    handle_departments(@product.taxons, params[:department], params[:custom])

#    @product.product_properties.find_by_property_id(Property.find_by_name("brand").id).value = params[:taxon][:brand_id]
#    brand_taxon = Spree::Taxon.find(params[:taxon][:brand_id])
#    @product.taxons << brand_taxon

    Rails.logger.info "***** Store taxon is #{@store.taxon.name}"
    @product.taxons << @store.taxon unless @store.taxon.nil?
    @product.tax_category_id = Spree::TaxCategory.find_by_name("Clothing").id    # REVIEW (aslepak) - need a category, is this the right one?
    @product.master.price = params[:product][:price]
    @product.master.sale_price = params[:product][:sale_price]
    @product.master.on_hand = 0
    @product.master.sku = "TEMP"
    @product.state = :published

    @selected ||= {}
    @selected["product_category"] = params[:taxon][:product_category_id]
    @selected["product_type"] = params[:taxon][:product_type_id]
    @selected["brand"] = params[:taxon][:brand_id]
    @selected["department"] = params[:department].present? ? params[:department].to_i : nil
    @selected["custom"] = params[:custom]

    is_dup = false
    @products = []
    params[:variant_data].each do |index, variant_data|
      variant_data.delete(:skip)
      variant_data.delete(:status)
      variant_data.delete(:product_id)
      variant_data.delete(:secondary_color) if variant_data[:secondary_color].blank?
      images = variant_data.delete(:images)
      per_size_data = variant_data.delete(:per_size_data)
      if is_dup
        product = @product.dup
      else
        product = @product
        is_dup = true
      end
      product.master = @product.master.dup
      product.master.price = params[:product][:price]
      product.master.sale_price = params[:product][:sale_price]
      product.master.sku = @product.sku
      product.price = @product.price
      product.sale_price = @product.sale_price
      product.prototype_id = @product.prototype_id
      product.taxons = Array.new(@product.taxons)
      product.properties = Array.new(@product.properties)
      product.tax_category_id = @product.tax_category_id
      product.state = :published

      per_size_data.each do |i, size_data|
        variant = Spree::Variant.new(variant_data.merge(:product => product, :size => size_data[:size], :on_hand => size_data[:on_hand], :price => product.price))
        product.variants << variant
        if images.present?
          images.each do |image_id|
            image = Spree::Image.find(image_id)
            variant.images << image
          end
        end
      end
      @products << product
    end

    # Put saving here, so that if there is an error, @products has all submitted data.
    master_id = nil
    @products.each_with_index do |product, index|
      product.product_id = master_id if master_id.present?
      unless product.save
        invoke_callbacks(:create, :fails)
        #render :action => :new
        return
      else
        master_id = product.id if index == 0
      end
    end
  end

  def update
    new_taxons = []
    
    category_taxon = nil
    taxon = @product.get_product_category_taxon
    taxon_id = (params[:taxon][:product_category_id].blank?) ? params[:taxon][:product_type_id].to_i : params[:taxon][:product_category_id].to_i
    if !taxon.nil? && taxon.id != taxon_id
      puts "**** adding Category taxon to list: #{Spree::Taxon.find(taxon_id).name}"
      category_taxon = Spree::Taxon.find(taxon_id)
      new_taxons << category_taxon
      if taxon.get_prototype_id != category_taxon.get_prototype_id
        @product = @product.root_product
        @product.remove_siblings_and_variants!
        puts "**** product #{@product.name} now has #{@product.products.size} siblings and #{@product.variants.size} variants"
      end

      set_prototype(params[:taxon])

      @product.get_siblings.each do |product|
        puts "**** Deleting #{taxon.name} from #{product.permalink}"
        product.taxons.delete(taxon)

        # reset the prototype information
        product.properties.delete_all
        product.add_properties_and_option_types_from_prototype
      end
    end

    @product.brand = Brand.find(params[:taxon][:brand_id].to_i)
    handle_departments(new_taxons, params[:department], params[:custom])

    @products = []
    params[:variant_data].each do |index, variant_data|
      images = variant_data.delete(:images)
      per_size_data = variant_data.delete(:per_size_data)
      if variant_data[:product_id].present?
        product = @product.get_siblings.find{|p| p.permalink == variant_data[:product_id]}
      else
        product = @product.dup
        product.master = @product.master.dup
        product.master.price = params[:product][:price]
        product.master.sale_price = params[:product][:sale_price]
        product.master.sku = @product.sku
        product.price = @product.price
        product.sale_price = @product.sale_price
        product.prototype_id = @product.prototype_id
        product.taxons = Array.new(@product.taxons)
        product.properties = Array.new(@product.properties)
        product.tax_category_id = @product.tax_category_id
        product.state = :published
        product.product_id = @product.id
      end

      product.attributes = product.attributes.merge(params[:product])
      product.taxons.delete(Spree::Taxon.departments)            # simply reset all Department taxons
      new_taxons.each do |new_taxon|
        product.taxons << new_taxon
      end
      product.taxons.compact!
      per_size_data.each do |i, size_data|
        if size_data[:id].present?
          variant = product.variants.find size_data[:id]
          variant.attributes = variant.attributes.merge(:size => size_data[:size], :on_hand => size_data[:on_hand], :price => product.price)
        else
          variant_data.delete(:skip)
          variant_data.delete(:status)
          variant_data.delete(:product_id)
          variant_data.delete(:secondary_color) if variant_data[:secondary_color].blank?
          variant = Spree::Variant.new(variant_data.merge(:product => product, :size => size_data[:size], :on_hand => size_data[:on_hand], :price => product.price))
        end
        product.variants << variant
        if images.present?
          images.each do |image_id|
            image = Spree::Image.find(image_id)
            variant.images << image
          end
        end
      end

      @products << product
    end

    # It's strange that invalid variant can be saved without any errors, so we have to check valid status here.
    all_variants = @products.map(&:variants).flatten
    invalid_variant = all_variants.find{|variant| !variant.valid?}
    if invalid_variant.present?
      prepare_before_edit
      render :action => :edit
      return
    end
    
    @products.each do |product|
      unless product.save
        prepare_before_edit
        render :action => :edit
        return
      end
    end
    
    flash.notice = flash_message_for(@product, :successfully_updated)
    redirect_to location_after_save
  end

  def edit
    prepare_before_edit
  end

  private

  def check_authorization
    authorize! :manage, self.class
  end
  
  def prepare_before_edit
    @editing = true
    @product = @product.root_product
    @form_name = "edit_product_#{@product.id}"

    cat_taxon = @product.get_product_category_taxon
    @selected["product_category"] = cat_taxon.nil? ? nil : cat_taxon.id
    @cat_index = @product_category.find_index(cat_taxon.parent)
    if @cat_index.nil?
      @cat_index = @product_category.find_index(cat_taxon)    # for Art/Toys/Electronics, look for Spree::Taxon itself, not its parent
      @selected["product_type"] = @product.get_product_category_taxon.id
    else
      @selected["product_type"] = @product.get_product_category_taxon.parent.id
    end
    puts "***** selected taxon is #{cat_taxon.name} and its index is #{@cat_index}"

    @selected["brand"] = @product.brand.id unless @product.brand.nil?
    @selected["custom"] = !@product.taxons.find_by_name("Custom Products").nil?

    case @product.get_sex
    when :childrens
      @selected["department"] = 3
    when :unisex
      @selected["department"] = 2
    when :womens
      @selected["department"] = 1
    else    # :mens
      @selected["department"]= 0
    end
  end
  
  protected

  def location_after_save
    #puts "in location after save"
    if params[:check].nil? || params[:check][:action].nil?
      #puts "url 1"
      #merchant_store_product_variants_url(params[:store_id], @product)
      main_app.merchant_store_path(@product.store)
    elsif params[:check][:action] == ACTIONS[:preview]
      #puts "url 2"
      spree.product_url(@product)
    elsif params[:check][:action] == ACTIONS[:previewlist]
      #puts "url 3"
      spree.products_url
    else
      #puts "url 4"
      main_app.merchant_store_product_variants_url(params[:store_id], @product)
    end
  end

  def load_store
    @store = Store.find(params[:store_id]) unless params[:store_id].blank?
  end

  def handle_departments(taxons, dept_id, custom)
    category = nil
    categories_id = Spree::Taxonomy.find_by_name("Categories").id
    taxons.each do |taxon|
      if taxon.taxonomy_id == categories_id
        category = taxon
        break
      end
    end
    unless category.nil?
      Rails.logger.info "*** got a category: #{category.name}"
    end
    
    @product.product_department = dept_id unless dept_id.blank?
    
    if (!category.nil? && ((category.name == "Art") || (category.name == "Toys") ||
            (!category.parent.nil? && (category.parent.name == "Electronics"))))
      Rails.logger.info "**** all sexes"
      taxons << Spree::Taxon.find_by_name("Men's")
      taxons << Spree::Taxon.find_by_name("Women's")
      taxons << Spree::Taxon.find_by_name("Children's")
    else
      if dept_id.to_s == "2"    # for Unisex, just add Men's and Women's
        taxons << Spree::Taxon.find_by_name("Men's")
        taxons << Spree::Taxon.find_by_name("Women's")
      else
        Rails.logger.info "**** dept taxon is #{@departments[dept_id.to_i][:name]}"
        taxons << Spree::Taxon.find_by_name(@departments[dept_id.to_i][:name])
      end
    end

    taxons << Spree::Taxon.find_by_name("Newly Added");
    taxons << Spree::Taxon.find_by_name("Custom Products") if (!custom.nil? && custom == "true")
  end

  def set_prototype(taxon_params)
    type_id = taxon_params[:product_type_id]
    category_id = taxon_params[:product_category_id]
    
    @product.product_type = Spree::Taxon.find_by_id(type_id)
    @product.product_category = Spree::Taxon.find_by_id(category_id)
    
    taxon = @product.product_type
    return true if taxon.nil?
    
    if taxon.prototype.nil? && !taxon_params[:product_category_id].blank?
      taxon = Spree::Taxon.find_by_id(taxon_params[:product_category_id])
      return true if taxon.nil?
    end
    
    if taxon.prototype.nil?
      @product.prototype_id = @miscPrototypeId
    else
      puts "**** setting prototype id to #{taxon.prototype.id}"
      @product.prototype_id = taxon.prototype.id
    end
  end

  def set_fullsize
    @fullsize = true
  end

end
