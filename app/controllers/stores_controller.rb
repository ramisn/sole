class StoresController < ApplicationController

  include Seo::ControllerMethods

  #-----------------Temporary Login Requirement----------------------------
  #before_filter :require_user

  def require_user
    if ##LOGIC##
      redirect_to '/user/sign_in'
    end
  end
  #-----------------Temporary Login Requirement----------------------------

  load_resource :only => [:show, :about, :store, :following, :followers, :policies]
  layout 'stores', :only => [:show, :about, :store, :following, :followers, :policies]

  #before_filter :beta_registration # temporary patch to limit access during beta
  before_filter :require_store, :only => [:show, :about, :store, :following, :followers, :policies]
  before_filter :set_meta_data, :only => [:show, :store, :about, :following, :followers, :policies, :index]
  helper Spree::ProductsHelper
  
  def index
    @title = "Streetwear | Urban Clothing | Shop"
    
    if params[:order].blank?

    elsif params[:order] == "a2z"
      sort_order = "stores.username ASC"
    elsif params[:order] == "z2a"
      sort_order = "stores.username DESC"
    else
      sort_order = "stores.followers_count DESC"
    end
    
    # TODO : Why sesarch for products? Isn't #index supposed to only return only stores. Commented it out to a simpler search method.
    
    # @taxons = Spree::Taxon.find(:all, :conditions => "parent_id is not NULL", :order => "name ASC").uniq
    # unless params[:cat].blank?
    #   taxon = Spree::Taxon.find(params[:cat])
    #   @stores = []
    #   @products = []
    #   unless taxon.blank?
    #     @searcher = Spree::Config.searcher_class.new(params.merge(:taxon => taxon.id))
    #     prods = @searcher.retrieve_products
    #   
    #     if prods.respond_to?(:results)
    #       prods.each_hit_with_result do |result,product|
    #         @products << product
    #       end 
    #     else 
    #       prods.each do |product| 
    #         @products << product
    #       end
    #     end
    #   
    #     @products.each do|prod|
    #       @stores << prod.store
    #     end
    #     unless @stores.blank?
    #       @stores = @stores.uniq.paginate(pagination_options)
    #     end
    #   end
    # else
    #   @stores = Store.order(sort_order).includes(:profile_image).page(params[:page]).per(Spree::Config[:products_per_page])
    # end
    # unless @stores.blank?
    #   @stores_followers = Follow.followers_count(@stores)
    # end

    case params[:order]
    when 'a2z'
      sort_order  = :username
      sort_dir    = :asc
    when 'z2a'
      sort_order  = :username
      sort_dir    = :desc
    when 'pop'
      sort_order  = :followers_count
      sort_dir    = :desc
    else
      sort_order  = :updated_at
      sort_dir    = :desc
    end
    
    if params[:keywords]

      
      @stores = Sunspot.search(Store) do
         fulltext params[:keywords]
         paginate :page => params[:page] || 1, :per_page => params[:per_page]
         order_by sort_order, sort_dir
      end.results
     
    else
      
      
      @stores = Store.order("stores.#{sort_order.to_param} #{sort_dir.to_param}").includes(:profile_image).page(params[:page]).per(Spree::Config[:products_per_page])     
    end

    @stores_followers = Follow.followers_count(@stores)
    render :layout => "/spree/layouts/spree_application"
    

  end
  
  def show #profile
    @default_product_groups = Spree::Config[:default_product_groups].split(',').map { |name| Spree::ProductGroup.find_by_name(name) }.compact
    @highlighting = :store
    
   
    params[:per] ||= 30
    params[:sort] ||= 'most-recent'
    params[:show_only] ||= 'all'

    
    if request.xhr? # ajax
      result = render_to_string "/spree/shared/_products", :layout => false, :locals => { :products => @store.taxon.published_products(params[:page]), :taxon => @taxon, :sort => params[:sort]}
      render :text => result
    end
    

  end
  
  def about
    @highlighting = :about
    @show_right_sidebar = true
  end

  def policies
    @show_right_sidebar = true
  end

  def store
    @highlighting = :store
  end
  
  def followers
    render :template => "/shared/follows_list", 
          :locals => {:title => "#{@store.display_name} is being Followed by:", 
                      :follows_type => :follower, 
                      :entity => @store}
  end
  
  def following
    render :template => "/shared/follows_list", 
          :locals => {:title => "#{@store.display_name} is following:", 
                      :follows_type => :following, 
                      :entity => @store}
  end

  protected
  def set_meta_data
    if params[:action] == "index"
      @title = I18n.t("meta.sellers")
    else
      require_store unless @store

      # Soletron | Store Name | Shop | Urban Clothing
      @title = @store.name_from_taxon + " | Shop | Urban Clothing"
    end
  end
  
  private
  
  def require_store
    @store = Store.find(params[:id])
    if @store.blank?
      redirect_to main_app.root_path
    elsif @store.username.downcase != params[:id].downcase  # SEO
      redirect_to store_path(@store.username), :status => :moved_permanently
    end
  end
  
end
