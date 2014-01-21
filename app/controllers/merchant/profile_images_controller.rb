require 'open-uri'
class Merchant::ProfileImagesController < Spree::BaseController
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
    if params[:facebook_picture]
      @profile_image = ProfileImage.new
      picture = JSON.parse(open("https://api.facebook.com/method/fql.query?format=json&query=SELECT+pic_big+FROM+page+WHERE+page_id=#{@store.facebook_id}").read)[0]
      if picture and picture['pic_big']
        picture_uri = picture['pic_big']
        @profile_image.attachment = open(picture_uri)
      else
        flash[:notice] = "Facebook does not have a picture for this page."
        @profile_image = nil
      end
    else
      @profile_image = ProfileImage.new(params[:profile_image])
    end
    if @profile_image
      #@profile_image.viewable = @store
      if @profile_image.save
        @profile_image.update_attributes(:viewable_id => @store.id, :viewable_type => @store.class.name)
        flash[:success] = "Your profile picture has been added."
        redirect_to main_app.merchant_store_profile_image_path(@store)
      else
        flash[:error] = "There was an error when adding your profile picture. Please try again."
        render :new
      end
    else
      flash[:error] = "There was no picture selected."
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
    if params[:facebook_picture]
      @profile_image = ProfileImage.new
      picture = JSON.parse(open("https://api.facebook.com/method/fql.query?format=json&query=SELECT+pic_big+FROM+page+WHERE+page_id=#{@store.facebook_id}").read)[0]
      if picture and picture['pic_big']
        picture_uri = picture['pic_big']
        @profile_image.attachment = open(picture_uri)
        @store.profile_image = @profile_image
        @store.profile_image.save
      else
        flash[:notice] = "Facebook does not have a picture for this page."
        @profile_image = nil
      end
    else
      @store.profile_image.update_attributes(params[:profile_image])
      @profile_image = @store.profile_image
    end
    if @profile_image and @profile_image.errors.empty?
      flash[:success] = "Your profile picture has been updated."
      redirect_to main_app.merchant_store_profile_image_path(@store)
    else
      flash[:error] = "There was an error when adding your profile picture. Please try again."
      render :edit
    end
  end
  
  def destroy
    if !@store.profile_image.destroy
      flash[:error] = "There was an error deleting your profile picture. Please try again."
    end
    redirect_to main_app.merchant_store_profile_image_path(@store)
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
    unless @store.profile_image
      flash[:error] = "You need to add a profile picture to perform that task."
      redirect_to new_merchant_store_profile_image_path
    end
  end
end
