Spree::TaxonsController.class_eval do
  include Seo::ControllerMethods

  #before_filter :beta_registration # temporary patch to limit access during beta
  before_filter :find_taxon, :only => [:show, :index]
  before_filter :load_default_product_groups, :only => [:show, :index]
  before_filter :set_price_filter, :only => :show
  before_filter :set_meta_data, :only => [:show, :index]
  before_filter :update_session, :only => [:show, :index]
  after_filter  :set_brand_filter, :only => [:show, :index]

  def show    

    
    return unless @taxon
    
    if params.has_key?(:filter)
      params[:product_group_name] = params[:filter]
    end
    if params.has_key?(:brand)
      params[:product_group_name] = params[:brand]
    end
    
    params[:per] ||= 30
    params[:sort] ||= 'most-recent'
    params[:show_only] ||= 'all'

    @searcher = Spree::Config.searcher_class.new(params.merge(:taxon => @taxon.id))
    @products = @searcher.retrieve_products

        
    @collection_title = @taxon.display_name
    
    
    set_filters
    set_min_max_price_values

    
    if request.xhr? # ajax
      result = render_to_string "/spree/products/_filtered_products", :layout => false, :locals => { :products => @products.results, :taxon => @taxon, :sort => params[:sort], :title => @collection_title}
      render :text => result

    else
      respond_with(@taxon)
    end

  end



  def load_default_product_groups
    Rails.logger.info "**** loading default product groups"

    g = Spree::Config[:default_product_groups].split(',').map do |name|
      Spree::ProductGroup.find_by_name(name)
    end

    @default_product_groups = g.compact
  end

  def set_meta_data
    return unless @taxon
    @title = "Streetwear " + @taxon.name
  end
  
  protected
  
  def find_taxon
    @taxon = Spree::Taxon.find_by_permalink!(params[:id])
  end

end
