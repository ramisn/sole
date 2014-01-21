Spree::ContentController.class_eval do
  ssl_allowed :show
  
  protected
  
  def close_window_ssl
    puts "close_window_ssl content override"
    super if !params[:path].start_with? "user_authentications/auth"
  end
end