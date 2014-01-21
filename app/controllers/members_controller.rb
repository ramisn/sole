class MembersController < ApplicationController
  include Spree::BaseHelper
  
  #-----------------Temporary Login Requirement----------------------------
  #before_filter :require_user

  def require_user
    if ##LOGIC##
      redirect_to '/user/sign_in'
    end
  end
  #-----------------Temporary Login Requirement----------------------------

  
  load_resource :class => "Spree::User", :only =>  [:show, :about, :followers, :following]
  layout 'members', :except => [:index]

  #before_filter :beta_registration # temporary patch to limit access during beta
  before_filter :require_user, :only => [:show, :about, :followers, :following]
  before_filter :show_right_sidebar
  before_filter :set_meta_data, :only => [:show, :about,  :index, :followers, :following]
  
  before_filter :set_sorting_order, :only => [:index]

  def index
    
    if !params[:keywords].nil?
     @members = Sunspot.search(Spree::User) do
       fulltext params[:keywords]
       paginate :page => params[:page] || 1, :per_page => params[:per_page]
     end.results
    else
      @members = Spree::User.viewable.order(@sort_order).includes(:profile_image, :user_authentications).page(params[:page] || 1).per( Spree::Config[:products_per_page])
    end
    
    @members_followers = Follow.followers_count(@members)

    render :layout => "/spree/layouts/spree_application"
  end
  

  
  def show #profile
    @highlighting = :solefeed
    @parent = @user
    if @acting_as == @parent
      @selected = :all
      @feed_items = @parent.all_feed_items(:page => params[:page])
      @view_more = @parent.all_feed_items_count > 20
    else
      @selected = :me
      @feed_items = @parent.my_feed_items(:page => params[:page])
      @view_more = @parent.my_feed_items_count > 20
    end
    render :template => '/feeds/generic'
  end
  
  def about
    @highlighting = :about
  end
  
  def followers
   
    render :template => "/shared/follows_list", 
      :locals => {:title => "#{@user.display_name} is being Followed by:",
      :follows_type => :follower,
      :entity => @user}
  end
  
  def following
    raise @user.display_name.inspect
    render :template => "/shared/follows_list", 
      :locals => {:title => "#{@user.display_name} is following:",
      :follows_type => :following,
      :entity => @user}
  end

  protected
  def set_meta_data
    if params[:action] == "index"
      @title = I18n.t("meta.members")
    else
      require_user unless @user

      name = ""
      name = @user.username unless (!@user.present? || @user.username.nil?)

      generate_social_meta_data(name)
    end
  end
  
  private
  
  def require_user
    @user = @member
    unless @user
      redirect_to main_app.root_path
    end
  end
  
  def show_right_sidebar
    @show_right_sidebar = true
  end
  
  def set_sorting_order
    if params[:order].blank?
      @sort_order = "spree_users.updated_at DESC"
    elsif params[:order] == "a2z"
      @sort_order = "spree_users.username ASC"
    elsif params[:order] == "z2a"
      @sort_order = "spree_users.username DESC"
    else
      @sort_order = "spree_users.followers_count DESC"
    end
  end
  
end
