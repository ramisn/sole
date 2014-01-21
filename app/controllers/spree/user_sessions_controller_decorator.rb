Spree::UserSessionsController.class_eval do
  helper Spree::ProductsHelper
  #after_filter :close_window_with_https, :only => [:new, :create]
  before_filter :set_return_to
  before_filter :tag_ssl_page

  ssl_required :confirmation
  
  def tag_ssl_page
	#Added by Brett to use for removing certain page elements during checkout process
	@ssl_page = true
  end
  
  # def create
  #    
  #    authenticate_user!
  #    
  #    if user_signed_in?
  #        respond_to do |format|
  #          format.html {
  #            flash[:notice] = t("logged_in_succesfully")
  #            
  #            redirect_back_or_default(products_path)
  #          }
  #          format.js {
  #            user = resource.record
  #            render :json => {:ship_address => user.ship_address, :bill_address => user.bill_address}.to_json
  #          }
  #        end
  #    else
  #      flash[:error] = I18n.t("devise.failure.invalid")
  #      render :new
  #    end
  #  end
  
  def confirmation
    if user = Spree::User.find_by_confirmation_token(params[:confirmation_token])
      user.confirm!
      flash[:error] = nil
      flash[:notice] = 'Email Confirmed.  Please sign in.'
    else
      flash[:error] = t('confirmation_failed')
    end
    render :action => :new
  end

  protected
  
  # This is to make sure that the omniauth_callbacks_controller does not redirect to the "/close_window" path
  # when you are in the main window.
  def set_return_to
    if session["user_return_to"].blank?
      session["user_return_to"] = request.referer || login_path
    end
  end
  
  #def close_window_with_https
  #  puts "in closing window with https"
  #  if RAILS_ENV == 'production'
  #    session[:need_to_close_with_https] = true
  #    puts "set to true"
  #  end
  #end
  
end

