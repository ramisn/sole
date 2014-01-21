Spree::BaseHelper.module_eval do
  include Spree::ProductsHelper
    
  def logo
    link_to "Soletron", main_app.redirects_path(:q => "home"), id: 'logo'
  end

  def get_product_details_url(store, product)
    main_app.edit_merchant_store_product_url(store, product)
  end

  def get_preview_product_url(product)
    preview_product_url(product)
  end

  def get_product_images_url(store, product)
    merchant_store_product_images_url(store, product)
  end

  # Make market_image, large_square_image available
  [:market, :large_square].each do |style|
    define_method "#{style}_image" do |product, *options|
      options = options.first || {}
      if product.images.empty?
        image_tag "noimage/#{style}.jpg", options
      else
        image = product.images.first
        options.reverse_merge! :alt => image.alt.blank? ? product.name : image.alt
        image_tag image.attachment.url(style), options
      end
    end
  end
  
  Spree::Image.attachment_definitions[:attachment][:styles].each do |style, v|
    define_method "#{style}_attachment_image" do |product, *options|
      options = options.first || {}
      images = (product.images + product.variant_images).uniq
      if images.empty?
        image_tag "noimage/#{style}.jpg", options
      else
        image = images.first
        options.reverse_merge! :alt => image.alt.blank? ? product.name : image.alt
        image_tag image.attachment.url(style), options
      end
    end
  end
  
  [:market, :large_square].each do |style|
    define_method "#{style}_attachment_image" do |product, *options|
      options = options.first || {}
      images = (product.images + product.variants.map(&:images).flatten).uniq
      if images.empty?
        image_tag "noimage/#{style}.jpg", options
      else
        image = images.first
        options.reverse_merge! :alt => image.alt.blank? ? product.name : image.alt
        image_tag image.attachment.url(style), options
      end
    end
  end
  
  def body_class
    @body_class ||= 'soletron'
    @body_class
  end
  

  def get_count(order)
    return 0 if order.nil?
    quantity = 0
    order.line_items.each do |line_item|
      quantity = quantity + line_item.quantity
    end
    return quantity
  end

  def link_to_cart
    #return "" if current_page?(cart_path)
    css_class = nil
    if current_order.nil? or current_order.line_items.empty?
      item_count = 0
      css_class = 'empty'
      content = ""
      title = "Your shopping cart is empty"
    else
      item_count = get_count(current_order)
		  if get_count(current_order) == 1
		  title = "Your shopping cart contains #{item_count} item"
		  else
		  title = "Your shopping cart contains #{item_count} items"
		  end
      content = content_tag(:span, item_count, :title => title)
      css_class = 'empty'  # BUGBUG (aslepak/brett) - do we want a different style for a full cart? See Spree's implementation, using the 'full' CSS class
    end
    link_to content, spree.cart_path, {:class => css_class, :title => title}
  end
	
	def taxons_tree(root_taxon, current_taxon, max_level = 1)
    return '' if max_level < 1 || root_taxon.nil? || root_taxon.children.nil? || root_taxon.children.empty?
		content_tag :ul, :class => 'sidenav' do
		  root_taxon.active_children.map do |taxon|
			  current = (current_taxon && current_taxon.self_and_ancestors.include?(taxon))
        content_tag :li do
          if current
            content_tag :text, taxon.display_name
          else
            link_to(taxon.display_name, seo_url(taxon))
          end
        end
		  end.join("\n").html_safe
		end
  end

  # The taxons we want to be shown for the "accessories" area -- arts, toys & electronics.
  def accessories_taxons_tree(current_taxon)
    #taxon_names = [I18n.t("taxons.art"), I18n.t("taxons.skateboards"), I18n.t("taxons.headphones"), I18n.t("taxons.cases"), I18n.t("taxons.speakers")]
    taxon = Spree::Taxon.find_by_permalink("categories/misc")
    taxon_names = (taxon.active_children.map(&:name) - [I18n.t("taxons.accessories")]).sort
    content_tag :ul, :class => 'sidenav' do
      taxon_names.map do |taxon_name|
        taxon = Spree::Taxon.find_by_name(taxon_name)
        current = (current_taxon && current_taxon.self_and_ancestors.include?(taxon))
        #current = current_taxon == taxon
        content_tag :li do
          if current
            content_tag :text, taxon.display_name
          else
            link_to(taxon.display_name, seo_url(taxon))
          end
        end
      end.join("\n").html_safe
    end
  end

  def get_featured_product_to_show(product)
    puts "*** looking at product: #{product.permalink}; feat_id: #{product.featured_image_id}"
    if !product.nil? && product.featured?
      image = Spree::Image.find_by_id(product.root_product.featured_image_id)
      product_show = image.nil? ? nil : image.viewable
      product = product_show unless (product_show.nil? || !product_show.is_a?(Spree::Product))
    end
    product
  end

  def menu_tab_core(r2l, *args)
    options = { }
    if args.last.is_a?(Hash)
      options = options.merge(args.pop)
    end

    if options[:style].nil?
      options[:style] = ""
    end
    
    destination_url = nil # Added because it might not be set due to !taxon.nil? check
    if (!options[:route].nil?)
      destination_url = send("#{options[:route]}_path")
      if (options[:label].nil?)
        options[:label] = args.first.to_s
      end
    else
      # BUGBUG(aslepak) - this gets tricky as our taxon names are now coming from en.yml, so they could get localized(!)
      taxon = menu_taxon_collection.find_by_name("#{args.first}")
      # Checking if taxon is not nil, because it was crashing the tests
      if !taxon.nil?
        if (options[:label].nil?)
          options[:label] = taxon.name
        end
        destination_url = seo_url(taxon)
      end
    end

    ## if more than one form, it'll capitalize all words
    link = link_to(options[:label].gsub(/\b\w/){$&.upcase}, destination_url, :class => "secondary-navigation-main-button selected")

    if (!taxon.nil?)
      sub_taxons = []
      sub_taxons << taxon.active_children.collect { |child| content_tag(:li, link_to(child.name, seo_url(child))) } unless taxon.children.empty?

      

      featured_product = taxon.featured_product
#      puts "****** featured product: #{featured_product}"
#      if !featured_product.nil?
#        featured_product = get_featured_product_to_show(featured_product)
#        content = link_to(small_image(featured_product), featured_product) + link_to(featured_product.accurate_title, product_path(featured_product))
#      else






        #  ALL OTHER ADS!----------------------------
        
        case taxon.name
        when 'Tops'
          img     = "2818/small/ALLERGIC_TO_BS_H_4e8b9885a1ecb.jpg"
          adName  = "Allergic to Bullshit"
        when 'Bottoms'
          img     = "1771/small/strip_red_front.png"
          adName  = "Nooka Strip"
        when 'Hats'
          img     = "3178/small/iconsnapbk_black.jpg"
          adName  = "Icon Adjustable"
        when 'Departments'
          img     = "2686/small/RebelGreen.jpg"
          adName  = "STORM of London Rebel"
        when 'Accessories'
          img     = "3278/small/SOLETRON_COVA_lo_150dpi_1.jpg"
          adName  = "Soletron Comic Book"
        when 'Footwear'
          img     = "2625/small/outline%20skull.jpg"
          adName  = "Outline Skull"
        end
          
        # if img  
        #           content = link_to(image_tag("https://s3.amazonaws.com/SpreeHeroku/assets/products/#{img}"), "http://soletron.com/track.php?page=shopDrop&location=shopDropDownAd&url=shop.soletron.com/redirects?q=ad#{taxon.name}") + link_to(adName, "/redirects?q=ad#{taxon.name}", :class => "simpleButton small green ad-name")
        #         end

      # featured = content_tag(:li, content)
      ad = {
        :src => "https://s3.amazonaws.com/SpreeHeroku/assets/products/#{img}",
        :name => adName,
        :description => '#TODO',
        :url  => "/redirects?q=ad#{taxon.name}"
      }
      
      sub_menu = render(:partial => '/shared/sub_nav_dropdown', :locals => {
        :title => link,
        :list => raw(sub_taxons.flatten.map{|li| li.mb_chars}.join),
        :ad => ad 
      })
    else
      sub_menu = ""
    end
    
    content_tag(:li, link + sub_menu, options)
  end

  def menu_tab(*args)
    menu_tab_core(false, *args)
  end

  def menu_tab_r2l(*args)
    menu_tab_core(true, *args)
  end
  
  def explore_tab
    link = link_to(t(:explore).gsub(/\b\w/){$&.upcase}, main_app.stores_path, :class => "secondary-navigation-main-button selected", :style => "width:110px;")
    sub_links = []
    sub_links << content_tag(:li, link_to(t(:soletron_sellers), main_app.stores_path))
    sub_links << content_tag(:li, link_to(t(:members), main_app.members_path))
    if @acting_as
      sub_links << content_tag(:li, link_to(t(:followers), entity_followers_path(@acting_as)))
      sub_links << content_tag(:li, link_to(t(:following), entity_following_path(@acting_as)))
    end
 #   sub_links << content_tag(:li, link_to(t(:high_profile), products_path))
 #   sub_links << content_tag(:li, link_to(t(:bloggers), products_path))
 #   sub_links << content_tag(:li, link_to(t(:popular), products_path))
 #   sub_links << content_tag(:li, link_to(t(:recent), products_path))

    ul1 = content_tag(:ul, raw(sub_links.flatten.map{|li| li.mb_chars}.join), :class => "left")

    # BUGBUG (aslepak) - temporarily hard-coded featured item
    
    
    
    
    
    #EXPLORE AD ------------------
    # content = link_to(image_tag("https://s3.amazonaws.com/SpreeHeroku/assets/profiles/1168/list/SOLETRON-(Red-in-Black-background-).jpg?1317922720"), 'http://soletron.com/track.php?page=shopDrop&location=shopDropDownAd&url=shop.soletron.com/redirects?q=adExplore') + link_to("Soletron Store", '/redirects?q=adExplore')
    # featured = content_tag(:li, content)
    #EXPLORE AD ------------------
    
    
    
    
    
    ul2 = content_tag(:ul, featured, :class => "right")
    
    submenu = render(:partial => "/shared/sub_nav_dropdown", :locals => {
      :title => link,
      :list =>  raw(sub_links.flatten.map{|li| li.mb_chars}.join),
      :ad   => {
        :name => "Soletron Store",
        :src  => "https://s3.amazonaws.com/SpreeHeroku/assets/profiles/1168/list/SOLETRON-(Red-in-Black-background-).jpg?1317922720",
        :url  => '/redirects?q=adExplore',
        :description => '#TODO'
      }
    })

    content_tag(:li, link + submenu)
  end

  def make_li_tag(taxon_name, class_name)
    taxon = menu_taxon_collection.find_by_name(taxon_name)
    unless taxon.nil?
      options = {}
      options[:class] = class_name unless class_name.nil?
      content_tag(:li, link_to(taxon_name, seo_url(taxon), options))
    else
        nil
    end
  end

  def misc_tab
    menu_taxon_collection
    link = link_to(t(:art_toys).gsub(/\b\w/){$&.upcase}, seo_url(menu_taxon_collection.find_by_name("Miscellaneous")), :class => "secondary-navigation-main-button selected", :style => "width:201px;")

    sub_links = []
    taxon = Spree::Taxon.find_by_permalink("categories/misc")
    menu_names = (taxon.active_children.map(&:name) - [I18n.t("taxons.accessories")]).sort
    #menu_names = [I18n.t("taxons.art"), I18n.t("taxons.toys"), I18n.t("taxons.skateboards"), I18n.t("taxons.headphones"), I18n.t("taxons.cases"), I18n.t("taxons.speakers")]
    class_name = 'sub-menu-padding'
    menu_names.each do |name|
      tag = make_li_tag(name, class_name)
      unless tag.nil?
        sub_links << tag
        class_name = nil
      end
    end

    # BUGBUG (aslepak) - temporarily hard-coded featured item

    submenu = render(:partial => "/shared/sub_nav_dropdown", :locals => {
      :title => link,
      :list =>  raw(sub_links.flatten.map{|li| li.mb_chars}.join),
      :ad   => {
        :name => "Soletron Earbuds",
        :src  => "https://s3.amazonaws.com/SpreeHeroku/assets/products/3381/large/MAIN.jpg",
        :url  => '/redirects?q=adToys',
        :description => '#TODO'
      }
    })
    content_tag(:li, link + submenu, :class => "last", :id => "sub-tab-misc")
  end

  def menu_taxon_collection
    return @menutaxoncollection if @menutaxoncollection.present?

    @menutaxoncollection = Spree::Taxon.where("menu_item")
  end

   def store_name_link(product, limit=true)
     if product.store
       name = product.store.display_name
     else
       name = ""
     end
   
     if limit
       display_name = name[0, Spree::Config[:store_max_characters].to_i] +
         (name.length > Spree::Config[:store_max_characters].to_i ? "..." : "")
     else
       display_name = name
     end
    link_to display_name, entity_profile_path(product.store), :class => 'info store-name', :title => name unless product.store.nil?
  end

  def default_meta_data(object, include_color = false, include_defaults = false)
    return "" if object.nil?

    return object.get_meta_keywords(include_color, include_defaults)
  end

  def default_meta_description(object, include_color = false, include_defaults = false)
    return "" if object.nil?

    return object.get_meta_description(include_color, include_defaults)
  end

  def meta_data_tags
    object = instance_variable_get('@'+controller_name.singularize)
    meta = { :keywords => Spree::Config[:default_meta_keywords], :description => Spree::Config[:default_meta_description] }

    meta[:keywords] = "" if meta[:keywords].nil?
    if object.kind_of?(Spree::Product) || object.kind_of?(Store)
      meta[:keywords] = default_meta_data(object, true)
      meta[:description] = default_meta_description(object, true)
    elsif object.kind_of?(Spree::Taxon)
      meta[:keywords] = object.name + ", " + meta[:keywords]
    else
      meta[:keywords] = @meta_keywords if @meta_keywords.present?
      meta[:description] = @meta_description if @meta_description.present?
    end
    if object.kind_of?(ActiveRecord::Base)
      meta[:keywords] = meta[:keywords] + ", " + (object[:meta_keywords].present? ? (object.meta_keywords) : "")
    end

    meta.map do |name, content|
	
	content = content.tr(%q{/-}, '')
	content = content.tr(%q{"'}, '')
	
      #tag('meta', :name => name, :content => content)
      
      "<meta name=\"#{name}\" content=\"#{content}\" />"
      
    end.join("\n")
  end

  def generate_social_meta_data(name = "")
    @title = I18n.t("meta.social_title")
    @meta_description = I18n.t("meta.social_description")
    @meta_keywords = "solefeed, #{name}, " + I18n.t("meta.social_keywords")
  end

  def get_params
    ret_params = "?"
    ret_params = ret_params + "filter=#{params[:filter]}&" unless params[:filter].blank?
    ret_params = ret_params + "color1=#{params[:color1]}&" unless params[:color1].blank?
    ret_params = ret_params + "color2=#{params[:color2]}&" unless params[:color2].blank?
    ret_params = ret_params + "size=#{params[:size]}&" unless params[:size].blank?
    ret_params = ret_params + "price_between=#{params[:price_between]}&" unless params[:price_between].blank?
    ret_params = ret_params + "keywords=#{params[:keywords]}&" unless params[:keywords].blank?
    ret_params = ret_params + "sex=#{params[:sex]}&" unless params[:sex].blank?

    if ret_params == "?"
      ""
    else
      ret_params
    end
  end

  [:mini, :small, :feed, :accordion, :marketplace, :product, :large].each do |style, v|
    define_method "#{style}_image" do |product, *options|
      options = options.first || {}
      diags = "{sc:#{product.sold_count} pvc: #{product.page_views} fc: #{product.favorites.count} ao: #{product.available_on.strftime("%m-%d-%y")}}"
      if product.images.empty?
        options.reverse_merge! :alt => "#{product.get_meta_description(true, false)} #{diags}"
        image_tag "/assets/noimage/#{style}.jpg", options
      else
        image = product.images.first
        options.reverse_merge! :alt => (image.alt.blank? ? "" : image.alt + ", ") + diags, :title => (image.alt.blank? ? "" : image.alt + ", ") + diags
        logger.debug "style is #{style}"
        image_tag image.attachment.url(style), options
      end
    end
  end

end
