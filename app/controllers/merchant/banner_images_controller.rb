class Merchant::BannerImagesController < Spree::Admin::ResourceController
  before_filter :authorized_store_member?
  before_filter :load_store#require_store
  before_filter :require_image, :only => [:edit, :update, :destroy]
  layout "merchant"
  
  def new
    if request.xhr?
      render :layout => false
    end
  end
  
  def create
    @banner_image = BannerImage.new(params[:banner_image])
    @banner_image.viewable = @store
    if @banner_image.save
      flash[:success] = "Your banner has been added."
      redirect_to merchant_store_banner_image_path(@store)
    else
      flash[:error] = "There was an error when adding your banner. Please try again."
      render :new
    end
  end
  
  def show
    
  end
  
  def edit
    if request.xhr?
      render :layout => false
    end
  end
  
  def update
    if @store.banner_image.update_attributes(params[:banner_image])
      flash[:success] = "Your profile picture has been updated."
      redirect_to merchant_store_banner_image_path(@store)
    else
      flash[:error] = "There was an error when adding your banner. Please try again."
      render :edit
    end
  end
  
  def destroy
    if !@store.banner_image.destroy
      flash[:error] = "There was an error deleting your banner. Please try again."
    end
    redirect_to merchant_store_banner_image_path(@store)
  end
  
private

  def load_store
    @store = Store.find(params[:store_id])
  end

  # most of this function is really obsolete now that we have authorized_store_member in BaseController
  def require_store
    @store = current_user.stores.find_by_id(params[:store_id])
    if @store.nil? && current_user.has_role?("admin")
      @store = Store.find_by_id(params[:store_id])
    end
    if @store.nil?
      flash[:error] = "You do not have permission to modify that store."
      redirect_to admin_path
    end
  end
  
  def require_image
    unless @store.banner_image
      flash[:error] = "You need to add a banner to perform that task."
      redirect_to merchant_store_banner_image_path(@store)
    end
  end
end
