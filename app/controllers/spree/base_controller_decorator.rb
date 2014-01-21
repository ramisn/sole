Spree::BaseController.class_eval do
  helper Spree::ProductsHelper
  
  # Anytime there is a an error authenticating using FGraph in the application, the error will be handled
  # rescue_from FGraph::OAuthError, :with => :handle_fgraph_oauth_error if RAILS_ENV == 'production'
  rescue_from Koala::Facebook::APIError, :with => :set_flash_faceboook
  

  
  prepend_before_filter :close_window_ssl
  
  #before_filter :require_login
  
  # brute force registration for beta
  def beta_registration
    return if current_user
    store_location
    redirect_to login_path
  end

  # inspired from - http://ramblinglabs.com/blog/2012/01/rails-3-1-adding-custom-404-and-500-error-pages

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActionController::UnknownAction, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  private

  def render_404(exception)
    #Rails.logger.error(exception)
    Exceptional::handle(exception)
    @not_found_path = exception.message
    respond_to do |format|
      format.html { render template: 'error/message_404', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def render_500(exception)
    #Rails.logger.error(exception)
    Exceptional::handle(exception)
    @error = exception
    respond_to do |format|
      format.html { render template: 'error/message_500', status: 500 }
      format.all { render nothing: true, status: 500}
    end
  end

  def authorized_store_member?
    if current_user.nil?
      flash[:error] = "You need to login to access the Merchant Panel."
      puts "**** redirect 1"
      redirect_to login_path
    else
      if current_user.has_role?('admin')
        true
      else
        store_id = (params.has_key? :store_id) ? params[:store_id] : params[:id]
        @store = Store.find(store_id)
        if @store.nil? or @store.users.find_by_id(current_user.id).nil?
          flash[:error] = "You are not authorized for this store."
          logger.info "**** MERCHANT PANEL FAILED AUTHORIZATION - user: #{current_user.email} - store: #{store_id}"
          puts "***** redirect 2: kicking you out, user #{current_user.email} lacking authorization for store #{store_id}"
          redirect_back_or_default main_app.root_path
        else
          check_merchant_authorization
        end
      end
    end
  end
  
  def check_merchant_authorization
    authorize! :manage, self.class
  end

  def product_belongs_to_store?
    product = Spree::Product.find_by_permalink(params[:product_id])
    if product.nil?
      flash[:error] = "No such product in this store"
      redirect_back_or_default main_app.root_path
    else
      taxon = product.taxons.find_by_taxonomy_id(Spree::Taxonomy.find_by_name("Stores").id)
      if taxon.nil? || taxon.store.nil?
        flash[:error] = "No such product in this store"
        puts "**** redirect 4"
        puts "this product's taxons: #{product.taxons.inspect}"
        puts "and the taxon we found: _#{taxon}_"
        redirect_back_or_default main_app.root_path
      elsif taxon.store == Store.find(params[:store_id])
          true
      else
        flash[:error] = "No such product in this store"
        puts "**** redirect 5"
        redirect_back_or_default main_app.root_path
      end
    end
  end

  protected


  
  def logout!
    error_message = flash[:error]
    
    # from Spree Auth's session destroy
    session.clear
    
    # from Devise's session destroy, assuming current_user based-on lib/devise/controllers/helpers.rb
    Devise.sign_out_all_scopes ? sign_out : sign_out(current_user)
    
    store_location
    
    flash[:error] = if error_message
      error_message
    else
      "You have been logged out. Please login again to access your account."
    end
    
    if Rails.env.production? or Rails.env.staging?
      redirect_to login_path, :protocol => 'https://'
    else
      redirect_to login_path
    end
  end
  
  def handle_koala_oauth_error(&block)
    begin
      yield
    rescue Koala::Facebook::APIError => e
      flash[:facebook] = true
    end
    #logout!
    #authorize_redirect
  end
  
  def set_flash_facebook
    flash[:facebook] = true
  end
  
  def handle_fgraph_oauth_error(&block)
    begin
      yield
    rescue FGraph::OAuthError => e
      flash[:facebook] = true
    end
    #logout!
    #authorize_redirect
  end
  
  def authorize_redirect
    store_location
    redirect_to authenticate_url('facebook')#user_omniauth_authorize_path('facebook')
  end
  
  def set_fullsize
    @fullsize = true
  end
  
  def close_window_ssl
    #puts "close_window_ssl"
    session[:need_to_close_with_https] = request.ssl?
    #puts "session needs https #{request.ssl?}"
  end
  
  # Common methods between products and taxons

  def set_min_max_price_values
    price_facet_rows = @products.facet(:price).rows.sort_by{|row| row.value}
    @min_price = price_facet_rows.first.try(:value) || 0
    @max_price = price_facet_rows.last.try(:value) || 1000
  end

  def set_price_filter

    if params[:product_group_query]
      query = Hash[*params[:product_group_query].split('/')].symbolize_keys
      @lower_price = query[:master_price_gte]
      @upper_price = query[:master_price_lte]
    end

    @lower_price ||= 0
    @upper_price ||= 1000
  end

  # Return a list of brands
  def set_brand_filter
    # return true if @products.nil?
    # return true if generic_results?
    # 
    # @brands = @products.map(&:brand).compact.uniq.sort_by(&:name)
    # true
  end

  def load_default_product_groups
    @default_product_groups = Spree::Config[:default_product_groups].split(',').map { |name| Spree::ProductGroup.find_by_name(name) }.compact
  end
  
  # Sets filters for filter summary and left column filters
  def set_filters
    filter_param_keys = [
      'brand', 'color',
      'size', 'department', 'keywords'
    ]
    @filters  = []
    filter_param_keys.each do |key|
      if !params[key].blank?
        params[key].split(',').each do |val|
          @filters << {:key => key, :val => val}
        end
      end
    end
    
    
    if params[:price]
      params[:price].split(',').each_slice(2).to_a.each do |range|
        @filters << {:key => 'price', :val => range.join(',')}
      end
    end

    if @products
      @brands       = @products.facet('brand_facet').rows.sort_by{ |brand| brand.value.capitalize}
      @departments  = @products.facet('department_facet').rows
    end
    
    @colors       = ['green', 'blue', 'purple', 'red', 'pink', 'beige', 'brown', 'yellow', 'orange', 'black', 'white', 'gray', 'teal', 'glowing', 'gold', 'silver']
    
    if !@taxon.nil? && @taxon.has_size?
      sizes        = (Spree::Product.sizes.sort_by{|size| size.position}.map(&:presentation) & @products.facet("size_facet").rows.map(&:value))
    end
  end
  
  
  private
  # Return true if there are no filters, nor search.
  #--
  # FIXME: filter_param_keys should not be hard-coded
  #++
  def generic_results?
    filter_param_keys = [
      'filter', 'product_group_query', 'branded', 'color1', 'color2',
      'size', 'sex', 'price_between', 'keywords'
    ]
      
    filter_param_keys.none? {|k| params.keys.member?(k)}
  end

  def add_to_products_collection(products)
    if @products.empty?
      @products = products
    else
      @products = @products.merge(products)
    end
  end
  
  def paginate_opts
    ({}).tap do |ret|
      ret[:per_page] = Spree::Config[:products_per_page]
      ret[:page] = params[:page]
    end
  end
  
  def update_session
    session[:per] = params[:per] ? params[:per] : session[:per]
    session[:per] ||= 30
  end

  
  

  
end
