class ShoutoutsController < Spree::BaseController
  before_filter :require_parent
  
  layout Proc.new { |controller| @parent.is_a?(Store) ? 'stores' : 'members' }
  
  def create
    @shoutout = Shoutout.create(params[:shoutout].merge({:poster => @acting_as, :posted_to => @parent}))
    
    if @shoutout.errors.empty?
      redirect_to(@store ? store_feed_path(@store) : member_feed_path(@user))
    else
      render :template => 'feeds/generic'
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

end
