class NotificationsController < Spree::BaseController
  
  before_filter :require_acting_as
  after_filter :set_notifications_to_viewed, :only => [:show]
  
  def show
    @notifications = if @acting_as.notifications.not_viewed.count < 25
      @acting_as.notifications.limit(25).order('created_at DESC')
    else
      @acting_as.notifications.not_viewed.order('created_at DESC')
    end
    
  
  end
  
protected
  
  def require_acting_as
    unless @acting_as
      flash[:notice] = "You need to login to view your notifications"
      redirect_back_or_default(main_app.root_path)
    end
  end
  
  def set_notifications_to_viewed
    @acting_as.notifications.not_viewed.update_all(:state => 'viewed')
    # set all not viewed notification to now viewed after the html is rendered
  end
  
end
