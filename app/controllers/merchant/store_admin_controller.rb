class Merchant::StoreAdminController < Spree::Admin::BaseController
  layout 'merchant'
  before_filter :authorized_store_member?, :only => [:edit, :create, :destroy]
  
  def edit
    @store = Store.find(params[:id])
  end
  
  def create
    @store = Store.find(params[:id])
    @user = Spree::User.find(:first, :conditions => {:email => params[:email]})
    if @user 
      if @store.users.find(:first, :conditions => {:id => @user.id})
        flash[:error] = 'This Email address is already an administrator of this store.'
        render :edit
      else
        if !@user.has_role?('merchant')
          @role = Spree::Role.find(:first, :conditions => {:name => 'merchant'})
          @user.roles << @role if @role
        end
        @store.users << @user
        redirect_to  main_app.edit_merchant_store_admin_url(@store)
      end
    else
      flash[:error] = 'This Email address does not have a Soletron account.'
      render :edit
    end
  end
  
  def destroy
    @store = Store.find(params[:id])
    @user = Spree::User.find(params[:user_id])
    @store.users.delete @user
    redirect_to  main_app.edit_merchant_store_admin_url(@store)
  end
end
