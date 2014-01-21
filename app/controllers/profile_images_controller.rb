require 'open-uri'
class ProfileImagesController < ApplicationController
  include ProfileImagesHelper
  
  layout 'account'
  before_filter :authenticate_user! 
  before_filter :require_image, :only => [:edit, :update, :destroy]
  
  def new
    
  end
  
  def create
    @profile_image = if params[:facebook_picture]
      image = ProfileImage.new
      
      picture_uri = JSON.parse(open("https://api.facebook.com/method/fql.query?format=json&query=SELECT+pic_big+FROM+user+WHERE+uid=#{current_user.facebook_auth.uid}").read)[0]['pic_big']
      
      image.attachment = open(picture_uri)
      image
    else
      ProfileImage.new(params[:image])
    end
    #@profile_image.viewable = current_user
    if @profile_image.save
      @profile_image.update_attributes(:viewable_id => current_user.id, :viewable_type => current_user.class.name)
      flash[:success] = "Your profile picture has been added."
      redirect_to account_profile_image_path
    else
      flash[:error] = "There was an error when adding your profile picture. Please try again."
      render :new
    end
  end
  
  def show
    
  end
  
  def edit
    
  end
  
  def update
    if params[:facebook_picture]
      @profile_image = ProfileImage.new
      
      picture_uri = JSON.parse(open("https://api.facebook.com/method/fql.query?format=json&query=SELECT+pic_big+FROM+user+WHERE+uid=#{current_user.facebook_auth.uid}").read)[0]['pic_big']
      
      @profile_image.attachment = open(picture_uri)
      current_user.profile_image = @profile_image
      current_user.profile_image.save
    else
      current_user.profile_image.update_attributes(params[:profile_image])
    end
    if current_user.profile_image.errors.empty?
      flash[:success] = "Your profile picture has been updated."
      redirect_to account_profile_image_path
    else
      @profile_image = current_user.profile_image
      flash[:error] = "There was an error when adding your profile picture. Please try again."
      render :edit
    end
  end
  
  def destroy
    if !current_user.profile_image.destroy
      flash[:error] = "There was an error deleting your profile picture. Please try again."
    end
    redirect_to account_profile_image_path
  end
  
private
  
  def require_user
    unless current_user
      flash[:error] = "You need to be logged in to modify your profile picture."
      root_url
    end
  end
  
  def require_image
    unless current_user.profile_image
      flash[:error] = "You need to add a profile picture to perform that task."
      redirect_to main_app.new_account_profile_image_path
    end
  end
end
