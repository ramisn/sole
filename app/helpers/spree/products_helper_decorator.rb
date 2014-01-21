Spree::ProductsHelper.module_eval do
  
  def product_price(product_or_variant, options={})
    options.assert_valid_keys(
      :format_as_currency,
      :show_vat_text,
      :uniform_price
    )    
    options.reverse_merge!(
      :format_as_currency => true,
      :show_vat_text => Spree::Config[:show_price_inc_vat],
      :uniform_price => true
    )
    
    price_shown = options.delete(:uniform_price) ?
      product_or_variant.uniform_price :
      product_or_variant.price

    amount = price_shown
    
    if Spree::Config[:show_price_inc_vat]
      amount += Spree::Calculator::Vat.calculate_tax_on(product_or_variant)
    end
    
    options.delete(:format_as_currency) ?
      format_price(amount, options) :
      amount
  end

  def color_checkbox(color)
    # color_checkbox('green')
    # <input type="checkbox" id="color:Greens" name="search[color1][]" value="colorGreen" />
    css_id = "color:#{color.titleize.pluralize}"
    value = "color#{color.titleize}"
    checked = params[:color1] =~ /#{value}/

    tag_options = { :type => 'checkbox', :id => css_id, :name => "with_option_value", :value => value }
    tag_options[:checked] = "checked" if checked

    tag("input", tag_options)
  end

  def product_name_link(product, limit=true)
    name = product.accurate_title
    if (limit)
      display_name = name[0, Spree::Config[:title_max_characters].to_i] +
        (name.length > Spree::Config[:title_max_characters].to_i ? "..." : "")
    else
      display_name = name
    end

    link_to display_name, product, {:class => 'info', :title => name}
  end

  def product_sale_name_link(product, limit=true)
    name = product.accurate_title
    if (limit)
      display_name = name[0, Spree::Config[:title_max_characters].to_i] +
        (name.length > Spree::Config[:title_max_characters].to_i ? "..." : "")
    else
      display_name = name
    end

    link_to display_name, product, {:class => 'info', :title => name}
  end

  def featured_image(product, options=nil)
    if !product.root_product.featured?
      product_image(product)
    else
      image = Spree::Image.find_by_id(product.root_product.featured_image_id)
      unless image.nil?
        image_tag Spree::Image.find(product.root_product.featured_image_id).attachment.url(:product)
      end
    end
  end
  
  def show_image(product, featured=false, style="product", options = {})

    style = "large" if style == true
    style = "market" if style == false
    meta_keywords = product.get_meta_keywords(false, true)
    meta_description = product.get_meta_description(false, true)
    meta_description ||= meta_keywords
    options.merge!(:title => meta_description, :alt => meta_keywords)
    if Spree::BaseController.helpers.respond_to?("#{style}_attachment_image")
      image = send("#{style}_attachment_image".to_sym, product, options)
    else
      image = product_attachment_image(product, options)
    end
    
    if product.is_a?(UserProduct)
      image
    elsif featured
      product = get_featured_product_to_show product
      link_to featured_image(product), product
    else
      link_to image, product
    end
  end

  def size_select(product)
    size_options = []
    quantity_options = []
    product.variants.each do |variant|      
      size_option_values = variant.size_options      
#      if size_option_values.size > 1
#        size_option_values.each do|val|
#          size_options << [val.presentation, variant.id] unless val.blank?
#        end        
#      else
        size_options << [size_option_values[0].presentation, variant.id] unless size_option_values.empty?
#      end
      
      quantity_options << {:size => variant.id, :count_on_hand => [variant.count_on_hand, 5].min}
    end
    size_options = size_options.sort { |l, r| l[0] <=> r[0] }
    {:sizes => size_options, :quantities => quantity_options}
  end

  def quantity_selects(product, size_options)
    has_size = !size_options[:sizes].empty?
    if size_options[:quantities].nil?
      variant = product.variants[0]
      size_options[:quantities] = []
      size_options[:quantities] << {:size => variant.id, :count_on_hand => [variant.count_on_hand, 5].min}
    end

    quantity_selects = []
    size_options[:quantities].each do |quant|
      if quant[:count_on_hand] > 0
        quantity_selects << select_tag(:quantity_pre, options_for_select((1..quant[:count_on_hand]).to_a.map {|q| [q, q]}), :include_blank => false, :id => quant[:size], :style => has_size ? 'display:none' : '')
      end
    end

    return quantity_selects
  end

  def variant_images_hash(product)
    product.variant_images.inject({}){|h, img| (h[img.viewable_id] ||= []) << img; h }
  end
  
  
  def sorting_options
    return [['Most Recent','most-recent'],['Most Popular','most-popular'],['A-Z','a2z'],['Z-A','z2a'], ['Price L to H','l2h'], ['Price H to L','h2l']]
  end

end
