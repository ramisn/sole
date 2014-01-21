class CollectionsController < Spree::BaseController
  include Spree::BaseHelper

  before_filter :require_member
  before_filter :set_highlighting
  before_filter :set_price_filter
  before_filter :set_meta_data
  layout 'members'
  helper Spree::ProductsHelper
  
  def show
	
	@is_collection_page = true #added by brett to remove ads from collection page
  
    options = params.merge(:per_page => 4)
    @shopping_cart = @user.product_search(:shopping_cart, options).page(params[:page])
    @favorites = @user.product_search(:favorites, options)
    @purchases = @user.product_search(:purchases, options)
    @uploads = @user.product_search(:uploads, options)
    @hide_product_pages = true
    @selected = :all
    # set_min_max_price_values
    # set_filters
    if request.xhr? # ajax
      result = render_to_string "collections/_show_products", :layout => false
      render :text => result
    end
  end
  
  def purchases
    @products = @user.product_search(:purchases, params)
    params_for_min_max = params.dup
    params_for_min_max.delete(:price)
    set_min_max_price_values(@user.product_search(:purchases, params_for_min_max))
    @selected = :purchases
    if request.xhr? # ajax
      result = render_to_string "shared/_products", :layout => false, :locals => { :products => @products, :taxon => @taxon}
      render :text => result
    else
      render :products
    end
  end
  
  def shopping_cart
    @products = @user.product_search(:shopping_cart, params)
    params_for_min_max = params.dup
    params_for_min_max.delete(:price)
    set_min_max_price_values(@user.product_search(:shopping_cart, params_for_min_max))
    @selected = :shopping_cart
    if request.xhr? # ajax
      result = render_to_string "shared/_products", :layout => false, :locals => { :products => @products, :taxon => @taxon}
      render :text => result
    else
      render :products
    end
  end
  
  def uploaded
    @products = @user.product_search(:uploads, params)
    params_for_min_max = params.dup
    params_for_min_max.delete(:price)
    set_min_max_price_values(@user.product_search(:uploads, params_for_min_max))
    @selected = :uploaded
    @hide_price = true
    if request.xhr? # ajax
      result = render_to_string "shared/_products", :layout => false, :locals => { :products => @products, :taxon => @taxon}
      render :text => result
    else
      render :products
    end
  end
  
  def favorites
    @products = @user.product_search(:favorites, params)
    params_for_min_max = params.dup
    params_for_min_max.delete(:price)
    set_min_max_price_values(@user.product_search(:favorites, params_for_min_max))
    @selected = :favorites
    if request.xhr? # ajax
      result = render_to_string "shared/_products", :layout => false, :locals => { :products => @products, :taxon => @taxon}
      render :text => result
    else
      render :products
    end
  end
  
  protected
  
  def require_member
    @highlighting = :collection
    if params[:member_id]
      @user = Spree::User.find(params[:member_id])
    end
    if @user
      @parent = @user
    else
      flash[:error] = "The member you were looking for could not be found."
      redirect_back_or_default(main_app.root_path)
    end
  end
  
  def set_highlighting
    @highlight = :collection
  end

  def set_min_max_price_values(products=nil)
    if products
      price_facet_rows = products.order('variants.price ASC')
      @min_price = if price_facet_rows.first
        price_facet_rows.first.master.price || 0
      else
        0
      end
      @max_price = if price_facet_rows.first
        price_facet_rows.last.master.price || 1000
      else
        1000
      end
    else
      @min_price = 0
      @max_price = 1000
    end
  end

  def set_price_filter
    if params[:price]
      params[:price][:lower] ||= 0
      params[:price][:higher] ||= 1000
    else
      params[:price] = {}
      params[:price][:lower] = 0
      params[:price][:higher] = 1000
    end
    @lower_price = params[:price][:lower]
    @upper_price = params[:price][:higher]
  end

  def set_meta_data
    require_member unless @user

    name = ""
    name = @user.username unless (!@user.present? || @user.username.nil?)

    generate_social_meta_data(name)
  end
  
end
