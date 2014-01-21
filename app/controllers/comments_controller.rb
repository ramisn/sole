class CommentsController < Spree::BaseController
  before_filter :require_acting_as
  before_filter :require_feed_item, :only => [:create]
  before_filter :require_comment, :only => [:destroy]
  before_filter :set_highlighting
  before_filter :set_entity, :only => [:create]
  
  def create
    if @feed_item.is_a?(Comment)
      flash[:error] = "Comments do not accept comments"
      redirect_to feed_item_path(@feed_item)
    else
      @comment = @feed_item.comments.create(params[:comment].merge({:commenter => @acting_as}))
      
      if @comment.errors.empty?
        respond_to do |format|
          format.html do
            if request.xhr?
              render :partial => 'feed_items/inline_comment', :layout => false, :locals => {:comment => @comment}
            else
              redirect_to feed_item_path(@feed_item)
            end
          end
        end
      else
        respond_to do |format|
          format.html do
            if request.xhr?
              render :partial => '/spree/shared/error_messages', :locals => {:target => @comment}
            else
              render :template => 'feed_items/show'
            end
          end
        end
      end
    end
  end
  
  def destroy
    if @comment.commenter == @acting_as
      @feed_item = @comment.feed_item
      @comment.destroy
      redirect_to feed_item_path(@feed_item)
    end
  end
  
protected
  
  def require_comment
    unless @comment = Comment.find(params[:id])
      flash[:error] = "The comment you were trying to reference could not be found."
      redirect_back_or_default(main_app.root_path)
    end
  end
  
  def require_feed_item
    unless @feed_item = FeedItem.find(params[:feed_item_id])
      flash[:error] = "The feed item you were looking for could not be found."
      redirect_back_or_default(main_app.root_path)
    end
  end
  
  def set_entity
    @entity = @feed_item.displayable
  end
  
  def set_highlighting
    @highlighting = :solefeed
  end
  
  def require_acting_as
    unless @acting_as
      flash[:notice] = "You need to have an account in order to post a comment."
      redirect_back_or_default(main_app.root_path)
    end
  end
  
end
