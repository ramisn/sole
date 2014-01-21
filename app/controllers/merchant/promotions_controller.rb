class Merchant::PromotionsController < Spree::Admin::PromotionsController
  before_filter :authorized_store_member?
  prepend_before_filter :set_store
  before_filter :promotion_belongs_to_store?, :except => [:index, :new, :create]
  before_filter :scope_collection, :only => [:index]
  before_filter :set_promotion_rules, :only => [:edit]
  update.before :update_before
  layout 'merchant'  
  
  protected
  
  def set_store
    unless @store = Store.find(params[:store_id] || params[:id])
      flash[:error] = "That store does not exist"
      redirect_back_or_default main_app.root_path
    end
  end
  
  def promotion_belongs_to_store?
    @promotion = Promotion.find(params[:id])
    
    if !@promotion or @promotion.store != @store
      flash[:error] = "The promotion was not found for this store."
      redirect_back_or_default main_app.root_path
    end
  end
  
  def scope_collection
    @collection = @collection.where(:store_id => @store).page(params[:page] || 1).per(Spree::Config[:products_per_page])
    @promotions = @collection
  end

  def build_resource
    extract_product
    @promotion = Spree::Promotion.new(params[:promotion])
    if params[:promotion] and params[:promotion][:calculator_type]
      @promotion.calculator = params[:promotion][:calculator_type].constantize.new
    end
    @promotion.store = @store
    set_product
    @promotion
  end
  
  def extract_product
    if params[:promotion] and params[:promotion][:product]
      @product = @store.taxon.products.find(params[:promotion][:product])
      params[:promotion].delete :product
    end
  end
  
  def set_product
    @promotion.product = @product if @product
  end
  
  def location_after_save
    edit_merchant_store_promotion_url(@store, @promotion)
  end  
  
  def update_before
    extract_product
    set_product
  end

  def load_data
    @calculators = [Spree::Calculator::BuyXGetYAtZPercentOff, Spree::Calculator::FlatPercent, Spree::Calculator::FreeItem]
  end
  
  def set_promotion_rules
    @promotion_rules = [Promotion::Rules::StoreTotal, Promotion::Rules::FirstOrder]
    if @store.username == "Soletron"
      @promotion_rules << Promotion::Rules::ItemTotal
    end
  end
  
end
