class Merchant::PromotionRulesController < Spree::Admin::PromotionRulesController
  before_filter :authorized_store_member?
  prepend_before_filter :set_store
  before_filter :promotion_belongs_to_store?, :except => [:index, :new, :create]
  layout 'merchant'
  
  def create
    @promotion = Promotion.find(params[:promotion_id])
    @promotion_rule = params[:promotion_rule][:type].constantize.new(params[:promotion_rule])
    @promotion_rule.promotion = @promotion
    if @promotion_rule.save
      flash[:notice] = I18n.t(:successfully_created, :resource => I18n.t(:promotion_rule))
    end
    respond_to do |format|
      format.html { redirect_to edit_merchant_store_promotion_path(@store, @promotion)}
      format.js   { render 'admin/promotion_rules/create', :layout => false }
    end
  end
  
  def destroy
    @promotion_rule = @promotion.promotion_rules.find(params[:id])
    if @promotion_rule.destroy
      flash[:notice] = I18n.t(:successfully_removed, :resource => I18n.t(:promotion_rule))
    end
    respond_to do |format|
      format.html { redirect_to edit_merchant_store_promotion_path(@store, @promotion)}
      format.js   { render 'admin/promotion_rules/destroy', :layout => false }
    end  
  end
  
  protected
  
    
  def set_store
    unless @store = Store.find(params[:store_id] || params[:id])
      flash[:error] = "That store does not exist"
      redirect_back_or_default main_app.root_path
    end
  end
  
  def promotion_belongs_to_store?
    @promotion = Promotion.find(params[:promotion_id])
    
    if !@promotion or @promotion.store != @store
      flash[:error] = "The promotion was not found for this store."
      redirect_back_or_default main_app.root_path
    end
  end

  
end
