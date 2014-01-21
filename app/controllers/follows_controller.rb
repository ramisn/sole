class FollowsController < Spree::BaseController
  before_filter :authenticate_user! 
  before_filter :require_parent, :only => [:create, :destroy]
  
  def create
    @follow = @acting_as.following_item(@parent)
    if @follow and @follow.active?
      flash[:notice] = "You are already following #{@parent.display_name}"
    else
      if @follow.nil?
        handle_koala_oauth_error do
          @follow = @acting_as.following.create(:following => @parent)
        end
      else
        # re-enable the follow relationship
        @follow.follow
      end
      if @follow.errors.empty?        
        @parent.update_attributes("followers_count" => @parent.followers_count.to_i + 1)
        flash[:success] = "You are now following #{@parent.display_name}"
      else
        flash[:error] = "There was an error when trying to follow #{@parent.display_name}. Please try again."
      end
    end
    
    redirect_to follow_redirect_path
  end
  
  def destroy
    @follow = @acting_as.following_item(@parent)
    if @follow.nil?
      flash[:notice] = "You are not currently following #{@parent.display_name}"
    elsif @follow.stop_following
      @parent.update_attribute("followers_count", @parent.followers_count.to_i - 1)
      flash[:success] = "You are no longer following #{@parent.display_name}"
    else
      flash[:error] = "There was an error when you stopped following #{@parent.display_name}. Please try again."
    end
    
    redirect_to follow_redirect_path
  end
  
protected
  
  def require_parent
    if params[:store_id]
      @parent = Store.find(params[:store_id])
    elsif params[:member_id]
      @parent = Spree::User.find(params[:member_id])
    end
    
    if @parent.nil?
      flash[:error] = "There was an error when trying to follow the entity. Please try again."
      redirect_back_or_default(main_app.root_path)
    end
  end
  
  def follow_redirect_path
    if request.referer
      puts "request.referer #{request.referer}"
      request.referer
    elsif @parent.is_a?(Store)
      main_app.store_path(@parent)
    elsif @parent.is_a?(Spree::User)
      main_app.member_path(@parent)
    else
      main_app.root_path
    end
  end
end
