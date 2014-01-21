module Merchant::ProductsHelper

  def available_date(available_on)
    curr_zone = Time.zone
    Time.zone = 'London'
    date = Time.zone.parse(available_on.to_s)
    Time.zone = curr_zone
    return date.to_date
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

  def link_to_function_feature_ajax(options)
    %Q{
      changeStar('#{options[:img_id]}');
      msg = 'hello world';
      jQuery.ajax({
        type: 'POST',
        url: '#{options[:url]}',
        data: ({_method: 'put', authenticity_token: AUTH_TOKEN}),
        dataType:'#{options[:dataType]}',
        error: #{options[:error]}
      });
    }
  end

  def sort_link(builder, attribute, *args)
    raise "Make sure this code is still required" if Gem.loaded_specs["meta_search"].version.to_s != "1.1.1"
    raise ArgumentError, "Need a MetaSearch::Builder search object as first param!" unless builder.is_a?(MetaSearch::Builder)
    attr_name = attribute.to_s
    name = (args.size > 0 && !args.first.is_a?(Hash)) ? args.shift.to_s : builder.base.human_attribute_name(attr_name)
    prev_attr, prev_order = builder.search_attributes['meta_sort'].to_s.split('.')

    options = args.first.is_a?(Hash) ? args.shift.dup : {}
    current_order = prev_attr == attr_name ? prev_order : nil

    if options[:default_order] == :desc
      new_order = current_order == 'desc' ? 'asc' : 'desc'
    else
      new_order = current_order == 'asc' ? 'desc' : 'asc'
    end
    options.delete(:default_order)

    html_options = args.first.is_a?(Hash) ? args.shift : {}
    css = ['sort_link', current_order].compact.join(' ')
    html_options[:class] = [css, html_options[:class]].compact.join(' ')
    options.merge!(
      builder.search_key => builder.search_attributes.merge(
        'meta_sort' => [attr_name, new_order].join('.')
      )
    )
    if options[:use_route]
      use_route = options.delete(:use_route)
      link_to [ERB::Util.h(name), order_indicator_for(current_order)].compact.join(' ').html_safe,
              instance_eval(use_route).url_for(options),
              html_options
    else
      link_to [ERB::Util.h(name), order_indicator_for(current_order)].compact.join(' ').html_safe,
              url_for(options),
              html_options
    end
  end
      
  def link_to_feature(product, options = {}, html_options={})
    options.reverse_merge! :dataType => 'script'
    options.reverse_merge! :img_id => "feature_img_#{product.id}"
    options.reverse_merge! :error => "function(r){ alert('An error has occurred - unable to change the Featured Status of this Product. Please make sure you do not already have 4 Products set as Featured, and the Product you are trying to feature has been Published to the Marketplace and contains at least one image.'); changeStar('#{options[:img_id]}'); }"

    if product.deleted? || !product.published? || product.is_a?(UserProduct)
      img = "/assets/deleted.png"
      if product.deleted?
        title = t(:product_deleted)
      elsif product.is_a?(UserProduct)
        title = t(:user_product_cant_feature)
      else
        title = t(:product_not_published)
        img = "/assets/yield.png"
      end
      image_tag(img, {:id => "#{options[:img_id]}", :title => "#{title}"})
    else
      if product.featured_image_id.nil?
        img = "/assets/gray_star.gif"
        title = t(:add_featured)
      else
        img = "/assets/green_star.gif"
        title = t(:remove_featured)
      end

      link_to_function image_tag(img, {:id => "#{options[:img_id]}", :title => "#{title}"}), link_to_function_feature_ajax(options), html_options
  end
  end
end
