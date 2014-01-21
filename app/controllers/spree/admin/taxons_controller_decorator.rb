Spree::Admin::TaxonsController.class_eval do
  before_filter :set_fullsize
  
  private

  def load_user
    Spree::User.find_by_id! params[:user_id]
  end
end