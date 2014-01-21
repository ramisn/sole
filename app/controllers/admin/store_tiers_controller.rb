class Admin::StoreTiersController < Spree::Admin::ResourceController
  include ResourceControllerOverrides
  before_filter :set_jquery
  before_filter :set_fullsize
  
  def index
    @store_tiers = StoreTier.paginate
  end
  
  protected

  def model_class
    StoreTier
  end
  
  def set_jquery
    @jquery_16 = true
  end
end
