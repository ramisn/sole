require 'json'
require 'json/pure'
Spree::ProductsController.class_eval do

  # SEO stuff
  # Check to see if the XHR request wants the layout present.
  before_filter lambda { |controller|
    if params[:layout] == 'false'
      controller.action_has_layout = false
    end
  }

  # SEO stuff
  AJAX_PRODUCT_SHOW_REGEX = /show\/(.*)/
  before_filter lambda {
    ef = params['_escaped_fragment_']
    if ef && (match_data = ef.match(AJAX_PRODUCT_SHOW_REGEX))
      product_id = match_data[1]
      params[:id] = product_id
    end
  }, only: [:show]

  # SEO stuff
  # If the user comes here via a color variant and not the root product,
  # We want to redirect to the root product, then load the color variant
  before_filter lambda {
    return if ignore_seo_redirect?
    @product = Spree::Product.find_by_permalink!(params[:id])
    return if @product.root_product == @product
    cookies[:load_variant] = params[:id]
    redirect_to @product.root_product
  }, only: [:show]

  # SEO stuff

  before_filter :load_variant, only: [:show]


  include Spree::ProductsHelper


  #-----------------Temporary Login Requirement----------------------------
  #before_filter :require_user

  def require_user
    if ##LOGIC##
      redirect_to '/user/sign_in'
    end
  end
  #-----------------Temporary Login Requirement----------------------------


  
  #before_filter :beta_registration # temporary patch to limit access during beta
  before_filter :check_merchant, :only => :preview
  before_filter :set_action, :only => :show
  before_filter :set_meta_data, :only => :show
  before_filter :load_default_product_groups, :only => :index
  before_filter :set_price_filter, :only => :index
  before_filter :increment_page_views, :only => :show
  before_filter :before_index, :only => [:index]

  before_filter :update_session, :only => [:index]
  before_filter :find_taxon, :only => [:show]     
  

  #for most popular product  
  def most_popular
  
    @sql = ActiveRecord::Base.connection()
    @most_popular_seller=@sql.select_rows("SELECT DISTINCT bs.store_id, s.username, a.id, a.attachment_file_name
                                        FROM products p
                                        LEFT JOIN brands_stores bs ON bs.brand_id = p.brand_id
                                        LEFT JOIN stores s ON s.id = bs.store_id
                                        LEFT JOIN assets a ON a.viewable_id = s.id
                                        WHERE a.viewable_type = 'Store'
                                        AND a.type = 'ProfileImage'
                                        ORDER BY p.page_views DESC
                                        LIMIT 6  ")

    i=0
    @most_array = Array.new(6){Array.new(3)}
    @most_popular_seller.each do |most|
      @most_array[i][0] = most[1]
      @most_array[i][1] = most[3]
      @most_array[i][2] = most[2]
      i+=1
    end
   
   @most=Array.new(6) {Hash.new(2)}
    
    for i in 0..5
    
      @most[i]['image'] = "http://s3.amazonaws.com/SpreeHeroku/assets/profiles/#{@most_array[i][2]}/small/#{@most_array[i][1]}"
      @most[i]['url']="http://shop.soletron.com/stores/#{@most_array[i][0]}"

    end 
    render "most_popular" ,:layout=>false
  end

  #for best seller product 

  def best_seller
   
    @sql = ActiveRecord::Base.connection()
    @best_sell_products= @sql.select_rows("SELECT DISTINCT p.id, p.permalink
                                          FROM line_items AS l
                                          JOIN orders AS o ON o.id = l.order_id
                                          LEFT JOIN variants AS v ON v.id = l.variant_id
                                          JOIN products AS p ON p.id = v.product_id
                                          WHERE o.payment_state = 'paid'
                                          GROUP BY l.variant_id, v.product_id
                                          ORDER BY sum( l.quantity ) DESC
                                          LIMIT 6
      ")
         
    @best_array=Array.new(6){Array.new(3)}
    i=0
    @best_sell_products.each do |best|
      #getting id for the image in the form of hash
      row_id = @sql.select_one("SELECT assets.id, assets.attachment_file_name FROM assets WHERE viewable_id= #{best[0]}"); 
      @best_array[i][0] = row_id["id"]
      @best_array[i][1] = row_id["attachment_file_name"]
      @best_array[i][2] = best[1]
      i+=1
       
    end   
    @best=Array.new(6) {Hash.new(2)}
   
    
    for i in 0..5
      @best[i]['image'] = "http://s3.amazonaws.com/SpreeHeroku/assets/products/#{@best_array[i][0]}/small/#{@best_array[i][1]}"
      @best[i]['url']= "http://shop.soletron.com/products/#{@best_array[i][2]}"      
    end
  
    render "best_seller" ,:layout=>false
  end
 
  
  def preview
    @action = :preview
    show
  end

  def check_merchant
    product = Spree::Product.find_by_permalink(params[:id])
    if product.nil? || product.store.nil? || (!current_user.admin? && product.store.users.find_by_id(current_user).nil?)
      flash[:error] = "Not authorized to preview products"
      redirect_to products_url
    end
  end

  def menu
    result = render_to_string "/shared/_secondary_menu_wrapper", :layout => false, :locals => { :checkout => false, :ssl_page => false }
    render :text => result
  end
  
  def before_index    
    @title = ""
    @product = Spree::Product.last
  end
    
  def index
    params[:per] ||= 30
    params[:sort] ||= 'most-recent'
    params[:show_only] ||= 'all'
    @searcher = Spree::Config.searcher_class.new(params)
    @products = @searcher.retrieve_products
    @title = "Streetwear | Urban Clothing | Shop"
    
    
    @collection_title = "Search results for '#{params[:keyword]}'" if params[:keyword]
        
    set_filters
    set_min_max_price_values
  
    if request.xhr? # ajax
      result = render_to_string "/spree/products/_filtered_products", :layout => false, :locals => { :products => @products.results, :taxon => @taxon, :sort => params[:sort], :title => @collection_title}
      render :text => result
    else
      respond_with(@products)
    end    
  end
  
  def accurate_title(product = @product)
    if product
      product.accurate_title
    else
      super()
    end
  end
  
  def accurate_title_for_colors(product = @product)
    if product
      product.accurate_title_for_colors
    else
      super
    end
  end
  

  protected
  # Track page_views per each product.
  def increment_page_views
    @product.increment!(:page_views)
    true
  end

  def set_action
    @action = :show
  end

  def set_meta_data
    @product = Spree::Product.find_by_permalink!(params[:id])
    return unless @product

    @title = @product.brand_name + " | " + @product.accurate_title + " | " + @product.get_category
  end

  # SEO.
  # If we can here via a redirect from a child product -- a color variant
  # then we'll want to load child after the redirect.
  def load_variant
    @variant_id = cookies.delete(:load_variant)
    if @variant_id
      params[:id] = @variant_id
    end
  end
  
  def find_taxon
    @taxon = @product.get_product_category_taxon
  end

  def add_to_products_collection(products)
    if @products.empty?
      @products = products
    else
      @products = @products.merge(products)
    end
  end

  def ignore_seo_redirect?
    request.xhr? || params['_escaped_fragment_']
  end
end
