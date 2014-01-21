module ApplicationHelper
  
  def custom_paginate(scope, options = {})
    options[:remote] ||= false
    outer_window = options.delete(:outer_window) || Kaminari.config.outer_window
    options[:window] = options.delete(:inner_window) || Kaminari.config.window
    options[:left] = options.delete(:left) || Kaminari.config.left
    options[:left] = outer_window if options[:left] == 0
    options[:right] = options.delete(:right) || Kaminari.config.right
    options[:right] = outer_window if options[:right] == 0
    options[:num_pages] = scope.num_pages
    options[:current_page] = scope.current_page
    options[:per_page] = scope.limit_value
    left_window_plus_one = 1.upto(options[:left] + 1).to_a
    right_window_plus_one = (options[:num_pages] - options[:right]).upto(options[:num_pages]).to_a
    inside_window_plus_each_sides = (options[:current_page] - options[:window] - 1).upto(options[:current_page] + options[:window] + 1).to_a
    options[:pages] = (left_window_plus_one + inside_window_plus_each_sides + right_window_plus_one).uniq.sort.reject {|x| (x < 1) || (x > options[:num_pages])}  

    render :partial => "custom_paginations/paginator", :locals => {:options => options}
  end
    
  def auth_hash(user)
    auths = {}
    if user and user.user_authentications
      user.user_authentications.each do |user_auth|
        auths[user_auth.provider] = user_auth
      end
    end
    auths
  end

  def current_user_picture_link
    auths = auth_hash(current_user)
    if auths['facebook']
      "https://graph.facebook.com/#{auths['facebook'].nickname}/picture"
    else
      "/assets/fpo-profile.jpg"
    end
  end

  def search_route(product_group_query)
    taxons_show = params[:controller] == 'taxons' && params[:action] == 'show'
    products_index = params[:controller] == 'spree/products' && params[:action] == 'index'

    if taxons_show
      if product_group_query.is_a?(Array)
        taxons_search_path(params[:id], product_group_query)
      else
        taxons_pg_search_path(params[:id], product_group_query)
      end
    elsif products_index
      if product_group_query.is_a?(Array)
        simple_search_path(product_group_query)
      else
        pg_search_path(product_group_query)
      end
    else
      url_for
    end
  end
  

  def getFilter(key, val)
    maps = {
      :branded => 'brand'
    }
    
    ar = val.split('/')
    if maps[ar[0]]
      return {:key => maps[ar[0]], :val => ar[1]}
    else
      return {:key => key, :val => val}
    end
  end
  
  
end

