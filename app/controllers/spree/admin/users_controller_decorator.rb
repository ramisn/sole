Spree::Admin::UsersController.class_eval do
  before_filter :set_fullsize
  helper "admin/taxons"
  def edit
    @stores = @user.stores
    if @stores.nil?
      puts "**** no stores"
    else
      puts @stores.count
    end
  end

  protected
  def set_fullsize
    @fullsize = false
  end
end
