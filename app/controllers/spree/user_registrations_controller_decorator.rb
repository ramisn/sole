Spree::UserRegistrationsController.class_eval do

  before_filter :set_return_url, :only => :create
  after_filter :add_email, :only => [:create]

  def add_email
    puts "**** adding email"
    if !@user.nil? && !@user.new_record? && (@user.receive_emails.to_i != 0)
      puts "**** got a user who signed up for emails: #{@user.email}"
    else
      puts "**** user #{@user.email} has opted out of emails"
    end
    puts "**** done adding email"
  end

  def set_return_url
	if session[:return_to].nil?
		session[:return_to] = params[:user][:return_url] if (params.key?(:user) && params[:user].key?(:return_url))
	end
    puts "**** return url is now set to |#{session[:return_to]}|"
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    redirect_url = session[:return_to] ? session[:return_to] : root_url
	puts "***** inactive sign up redirect to |#{redirect_url}|"
    session[:return_to] = nil

	return redirect_url
  end

end
