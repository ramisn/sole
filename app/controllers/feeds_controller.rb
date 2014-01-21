class FeedsController < ApplicationController
  include Spree::BaseHelper

  #before_filter :beta_registration # temporary patch to limit access during beta
  before_filter :require_parent
  before_filter :set_highlighting
  before_filter :set_meta_data
  helper Spree::ProductsHelper
  
  layout Proc.new { |controller| @parent.is_a?(Store) ? 'stores' : 'members' }
  
  def show
    @selected = :me
    @feed_items = @parent.my_feed_items(:page => params[:page])
    #puts "feed items #{@feed_items.inspect}"
    @view_more = @parent.my_feed_items_count > 20
    @show_right_sidebar = true
    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => "feed_items/item", :collection => @feed_items, :as => :feed_item, :layout => nil
        else
          render :template => 'feeds/generic'
        end 
      end
    end
  end
  
  def feed
    @selected = :me
    @feed_items = @parent.my_feed_items(:page => params[:page])
    @view_more = @parent.my_feed_items_count > 20
    @show_right_sidebar = true
    respond_to do |format|
      format.atom do
        @title = "#{@parent.display_name}'s Recent Activity on Soletron"
        @updated = @feed_items.first.updated_at unless @feed_items.empty?
        render :layout => false
      end
    end
  end
  
  def all
    @selected = :all
    @feed_items = @parent.all_feed_items(:page => params[:page])
    @view_more = @parent.all_feed_items_count > 20
    @show_right_sidebar = true
    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => "feed_items/item", :collection => @feed_items, :as => :feed_item, :layout => nil
        else
          render :template => 'feeds/generic'
        end  
      end
    end
  end
  
  def network
    @hide_shoutout = true
    @selected = :network
    @feed_items = @parent.network_feed_items(:page => params[:page])
    @view_more = @parent.network_feed_items_count > 20
    @show_right_sidebar = true
    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => "feed_items/item", :collection => @feed_items, :as => :feed_item, :layout => nil
        else
          render :template => 'feeds/generic'
        end  
      end
    end
  end
  
protected
  
  
  def require_parent
    @parent = if params[:store_id]
      @store = Store.find(params[:store_id])
      @store
    elsif params[:member_id]
      @user = Spree::User.find(params[:member_id])
      @user
    end
    
    if @parent.nil?
      flash[:error] = "There was an error when trying to follow the entity. Please try again."
      redirect_back_or_default(main_app.root_path)
    end
  end
  
  def set_highlighting
    @highlighting = :solefeed
  end

protected
  def set_meta_data
    require_parent unless @parent
    
    name = ""
    name = @store.name_from_taxon unless !@store.present?
    name = @user.username unless (!@user.present? || @user.username.nil?)

    generate_social_meta_data(name)
  end
  
end
