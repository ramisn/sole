class FeedItemsController < Spree::BaseController
  include ProfilesHelper
  
  before_filter :require_feed_item
  before_filter :require_parent
  before_filter :set_highlighting
  
  layout Proc.new { |controller| @parent.is_a?(Store) ? 'stores' : 'members' }
  
  def show
    @comments = if @feed_item.feedable.is_a?(Shoutout)
      @feed_item.self_and_sibling_comments.order('created_at ASC')
    else
      @feed_item.comments.order('created_at ASC')
    end
  end
  
  def destroy
    if @feed_item.feedable.is_a?(Shoutout) and @feed_item.feedable.poster == @acting_as
      @feed_item.feedable.destroy
      #redirect_back_or_default(entity_profile_path(@feed_item.displayable))
    elsif @feed_item.displayable == @acting_as
      @feed_item.destroy
      #redirect_back_or_default(entity_profile_path(@feed_item.displayable))
    #else
      #redirect_back_or_default(entity_profile_path(@feed_item.displayable))
    end
    if request.referer.blank?
      redirect_back_or_default(entity_profile_path(@feed_item.displayable))
    else
      redirect_to request.referer
    end
  end
  
protected
  
  def require_feed_item
    @feed_item = FeedItem.find(params[:id])
    if @feed_item.nil?
      flash[:error] = "The feed item you were trying to view does not exist."
      redirect_back_or_default(main_app.root_path)
    elsif @feed_item.feedable.is_a?(Comment)
      # Comments cannot be commented on, so I don't know if there's a reason for them to have their own page.
      redirect_to feed_item_path(@feed_item.feedable.feed_item)
    end
  end
  
  def set_highlighting
    @highlighting = :solefeed
  end
  
  def require_parent
    @parent = if @feed_item.displayable.is_a?(Store)
      @store = @feed_item.displayable
      @store
    elsif @feed_item.displayable.is_a?(Spree::User)
      @user = @feed_item.displayable
      @user
    end
    
    if @parent.nil?
      flash[:error] = "There was an error when trying to follow the entity. Please try again."
      redirect_back_or_default(main_app.root_path)
    end
  end

end
