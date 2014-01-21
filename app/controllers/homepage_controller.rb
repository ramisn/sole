class HomepageController < Spree::BaseController
  load_resource :class => "Spree::User"
  
  def index
    render :layout => "spree_application"
  end
  
  def show #profile
    @highlighting = :show
  end
  
  def about
    @highlighting = :about
  end
  
private
  
  def require_user
    unless @user = Spree::User.find(params[:id])
      redirect_to main_app.root_path
    end
  end
  
  def load_followers
    @total_followers = @user.followers.active.count
    @select_followers = @user.followers.active.limit(10).inject([]) do |array, item|
      array << item.follower
      array
    end
  end
  
  def load_following
    @total_following = @user.following.active.count
    @select_following = @user.following.active.limit(10).inject([]) do |array, item|
      array << item.following
      array
    end
  end
  
end
