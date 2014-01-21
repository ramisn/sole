class FeedbacksController < Spree::BaseController
  include Spree::BaseHelper
  
  before_filter :redirect_back_or_home
  before_filter :find_entity, :only => [:index, :needed]
  before_filter :find_feedback, :only => [:edit, :update, :destroy]
  before_filter :set_highlighting
  before_filter :can_access, :only => [:needed, :edit, :update, :destroy]
  before_filter :set_meta_data, :only => [:index, :needed]
  
  def index
    @feedbacks = if @parent.is_a?(Store)
      @parent.feedbacks
    else
      Feedback.where(:order_id => @parent.orders)
    end.done.includes([{:order => :user}, :store])
    
    @filter = params[:sort_by] || 'date_latest'
    case @filter
    when 'date_latest'
      @feedbacks = @feedbacks.order("feedback_left_at DESC")
    when 'date_oldest'
      @feedbacks = @feedbacks.order("feedback_left_at ASC")
    when 'rating_high_low'
      @feedbacks = @feedbacks.order("rating DESC")
    when 'rating_low_high'
      @feedbacks = @feedbacks.order("rating ASC")
    end
    
    @feedbacks = @feedbacks.page(params[:page]).per(20)
    
    @selected = :done
    
    if @user
      render :layout => 'members'
    else
      render :layout => 'stores'
    end
  end
  
  def needed
    @feedbacks = if @parent.is_a?(Store)
      @parent.feedbacks
    else
      Feedback.where(:order_id => @parent.orders)
    end.needed.includes([{:order => :user}, :store]).page(params[:page]).per(20)
    
    @selected = :needed
    
    if @user
      render :layout => 'members'
    else
      render :layout => 'stores'
    end
  end
  
  def edit
    render :layout => 'account'
  end
  
  def update
    @feedback.update_attributes(params[:feedback])
    if @feedback.needed?
      @feedback.added
    end
    if @feedback.errors.empty?
      flash[:success] = "Your feedback was added. Thank you."
      redirect_to member_feedbacks_path(current_user)
    else
      flash[:error] = "There was a problem when updating your feedback"
      render :edit, :layout => 'account'
    end
  end
  
  def destroy
    @feedback.destroy
    if @feedback.errors.empty?
      
    else
      
    end
  end
  
  protected
  
  def redirect_back_or_home
    redirect_back_or_default(main_app.root_path)
  end
  
  def find_order
    @order = @user.orders.find(params[:order_id])
  end
  
  def set_highlighting
    @highlighting = :feedback
  end
  
  def find_entity
    @parent = if params[:member_id]
      @user = Spree::User.find(params[:member_id])
    elsif params[:store_id]
      @store = Store.find(params[:store_id])
      @store
    else
      @user = current_user
      @user
    end
  end
  
  def find_feedback 
    @feedback = Feedback.find(params[:id])
    unless @feedback.order.user == current_user
      flash[:error] = "The feedback you were looking for could not be found."
      redirect_to member_feedbacks_path(current_user)
    end
  end
  
  def can_access
    if @parent.is_a?(Store) and (current_user.nil? or !current_user.stores_users.find_by_store_id(@parent))
      flash[:error] = "You do not have permission to modify the feedback of this store."
      redirect_to store_feedbacks_path(@parent)
    elsif @parent.is_a?(Spree::User) and current_user != @parent
      flash[:error] = "You do not have permission to modify the feedback of this member."
      redirect_to member_feedbacks_path(@parent)
    end
  end

  def set_meta_data
    find_entity unless @parent

    if @store.present?
      @title = @store.name_from_taxon + " | Shop | Urban Clothing"
      @meta_keywords = @store.get_meta_keywords(true, false)
      @meta_description = @store.get_meta_description(true, false)
    else
      name = (!@user.present? || @user.username.nil?) ? "" : @user.username
      generate_social_meta_data(name)
    end
  end
  
end
