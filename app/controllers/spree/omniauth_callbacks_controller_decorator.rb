require 'model_request_info'

Spree::OmniauthCallbacksController.class_eval do
  include ModelRequestInfo
  
  #skip_before_filter :require_login
  before_filter :set_request_for_models
  skip_before_filter :reset_https_flag

  # Needs to be in this order to work properly, ensure_access_token gets called first
  #after_filter :render_to_close_window
  #after_filter :check_data, :only => [:facebook]
  #after_filter :check_permissions, :only => [:facebook]
  #after_filter :ensure_access_token, :except => [:close_window]
  
  #rescue_from Errno::ECONNRESET, :with => :connection_reset
  ssl_allowed :close_window
  
  def close_window
    # This is to check specifically for when the /login page is used to create the popup,
    # because the login page uses ssl.
    #if (need_ssl? and !request.ssl?)
    #  session[:need_to_close_with_https] = nil
    #  redirect_to "/close_window", :protocol => 'https://'
    #else
    #  render :layout => nil
    #end
    close_window_redirect(true)
  end
  
protected
  
  def after_omniauth_failure_path_for(scope)
    "/close_window"
  end
  
  # Cleaning up the process of logging in via social networks by modifying and overriding this method
  # from the SpreeSocial gem.
  def social_setup(provider)
    omniauth = request.env["omniauth.auth"]
    facebook_display = session['omniauth.facebook.display']

    if request.env["omniauth.error"].present?
      flash[:error] = I18n.t("devise.omniauth_callbacks.failure", :kind => provider, :reason => I18n.t(:reason_user_was_not_valid))
      if facebook_display == 'popup'
        return render :close_window, :layout => nil
      else
        return redirect_back_or_default(root_url)
      end
    end

    existing_auth = UserAuthentication.where(:provider => omniauth['provider'], :uid => omniauth['uid'].to_s).first
    
    email = omniauth["extra"]["user_hash"]["email"]
    email_user = Spree::User.find_by_email(email)
    
    # If the person had created a soletron account and now has a Facebook auth linked to an anonymous account
    # => then destroy the link to the anonymous account
    # The other checks in the code, will display the proper errors, since existing_auth is set to nil
    if existing_auth and existing_auth.user.anonymous? and email_user
      existing_auth.destroy
      existing_auth = nil
    end
    
    ##
    # This statement slightly modified for Soletron
    ##
    #signing back in from a social source
    user = if existing_auth
      existing_auth.user
    elsif current_user# adding a social source - changed to elsif from else
      current_user
    else
      # New for Soletron.  Create a new user, not an anonymous one
      
      # If the email provided by the provider already has a Soletron account, then it will ask the person to
      # login with that account and link to the provider
      #
      # This also handles the case above where the existing_auth is attached to an anonymous user, but
      # the database has a user already attached to the email address.
      if email_user
        flash[:error] = "A Soletron account has already been created for the email supplied by your #{omniauth['provider'].capitalize} account. For your security, please login with your Soletron account, then link your account to #{omniauth['provider'].capitalize}"
        if facebook_display == 'popup'
          return render :close_window, :layout => nil
        else
          return render :template => "user_sessions/new"
        end
      end
      
      random_password = Digest::SHA512.hexdigest "#{email}-#{rand()}"
      user = Spree::User.new(:email => email, :password => random_password, :password_confirmation => random_password, :name => omniauth["extra"]["user_hash"]["first_name"], :birthday => (DateTime.now - 21.year), :confirmed_at => DateTime.now)
      user.generate_username
      #at_sym = email.index("@")
      #if at_sym.nil?
      #  username = email
      #else
      #  username = email[0,at_sym]
      #end
      #random_username = "#{username}#{rand(1000)}"
      #user = Spree::User.create(:email => email, :password => random_password, :password_confirmation => random_password, :name => omniauth["extra"]["user_hash"]["first_name"], :birthday => (DateTime.now - 21.year), :username => random_username, :confirmed_at => DateTime.now)
      if !user.save!    # BUGBUG (aslepak) - need error handling in case .create fails (likely reason - we randomly generated a non-unique username), the two lines below don't seem to be working...
        puts "user failed because #{user.errors}"
        flash[:error] = "Failed to create a Facebook user - please try again. #{user.errors}"
        redirect_back_or_default(account_url)
      end
      user
    end
    
    ## Commented out for Soletron, because the else above handles it
    #user ||= Spree::User.anonymous!

    user.associate_auth(omniauth) unless existing_auth
    
    # add Facebook access token
    if omniauth['provider'] == 'facebook'
      puts "updating facebook auth to token #{omniauth["credentials"]["token"]}"
      user.facebook_auth.update_attributes(:access_token =>  omniauth["credentials"]["token"])
    end

    if current_order
      current_order.associate_user!(user)
      session[:guest_token] = nil
    end
    
    #puts "referer #{request.referer}"
    
    if user.anonymous? # This should not happen anymore, but leaving it
      random_password = Digest::SHA512.hexdigest "#{email}-#{rand()}"
      user.update_attributes(:email => email, :password => random_password, :password_confirmation => random_password, :name => omniauth["extra"]["user_hash"]["first_name"], :birthday => (DateTime.now - 21.year))
      
      #session[:user_access_token] = user.token #set user access token so we can edit this user again later
      
      #flash.now[:notice] = t("one_more_step", :kind => omniauth['provider'].capitalize)
      #render(:template => "user_registrations/social_edit", :locals => {:user => user, :omniauth => omniauth})
    elsif current_user
      # turned end if of flash[:error] into a statement
      if existing_auth && (existing_auth.user != current_user)
        flash[:error] = t("attach_error", :kind => omniauth['provider'].capitalize)# if existing_auth && (existing_auth.user != current_user)
      #elsif omniauth['provider'] == 'facebook'
      #  pull_facebook_data(user)
      #  check_permissions(user)
      #  check_data(user)
      end
      
      #if facebook_display == 'popup'
      #  render :close_window, :layout => nil
      #else
      #  redirect_back_or_default(account_url)
      #end
    else
      #if omniauth['provider'] == 'facebook'
      #  pull_facebook_data(user)
      #  check_permissions(user)
      #  check_data(user)
      #end
      sign_in(user, :event => :authentication)
      
      #if facebook_display == 'popup'
      #  render :close_window, :layout => nil
      #else
      #  redirect_back_or_default(account_url)
      #end
    end
    
    if omniauth['provider'] == 'facebook' and flash[:error].nil? and flash[:alert].nil?
      pull_facebook_data(user)
      check_permissions(user)
      check_data(user)
    end
    
    if facebook_display == 'popup'
      close_window_redirect(true) # redirect_to '/close_window', :layout => nil
    elsif session["user_return_to"] != login_path
      redirect_back_or_default(account_url)
    else
      redirect_to(account_url)
    end
  end
  
  def connection_reset
    flash[:error] = "There was an error when accessing the outside service. Please login again."
    #logout!
    
    if facebook_display == 'popup'
      render :close_window, :layout => nil
    else
      redirect_back_or_default(account_url)
    end
  end
  
  # This adds the access_token to the authentication that is currently being logged in with
  def ensure_access_token
    if current_user
      @omniauth_data = request.env["omniauth.auth"]
      @existing_auth = UserAuthentication.where(:provider =>  @omniauth_data['provider'], :uid =>  @omniauth_data['uid'].to_s).first
      @existing_auth.update_attributes(:access_token =>  @omniauth_data["credentials"]["token"])
    end
  end
  
  def pull_facebook_data(user)
    handle_koala_oauth_error do
      @graph = Koala::Facebook::GraphAPI.new(user.facebook_auth.access_token)
      data = @graph.batch do |batch_api|
        batch_api.get_object('me/permissions')
        batch_api.get_object('me/accounts')
        batch_api.get_object('me/friends')
        batch_api.get_object('me/likes')
      end
      @permissions = data[0][0]
      @accounts = data[1]
      @friends = data[2]
      @likes = data[3]
    end
  end
  
  # This checks to see if the person has Facebook's manage pages permission enabled
  def check_permissions(user)
    # Now catching all FGraph::OAuth errors in the base controller, so this is unnecessarybu
    
    #puts @permissions.inspect
    if @permissions['manage_pages'] == 1
      #user.update_attributes(:facebook_manage_pages => true)
      user.update_attribute_without_callbacks(:facebook_manage_pages, true)
      #puts "user is #{user.inspect}"
      #puts "facebook manage pages is #{user.facebook_manage_pages}"
      
      # Get the access tokens for all of the pages the user has
      #puts @accounts.inspect
      if @accounts and @accounts.size > 0
        access_tokens = @accounts.inject({}) do |hash, page|
          if page
            hash[page['id']] = page['access_token']
          end
          hash
        end
        
        # Update the stores with new access_tokens for the user
        user.stores_users.includes(:store).each do |store_user|
          if access_tokens.has_key?(store_user.store.facebook_id)
            store_user.update_attributes(:facebook_access_token => access_tokens[store_user.store.facebook_id])
          end
        end
      end
    else
      #puts "\n\nsetting facebook manage pages to false\n\n"
      user.update_attributes(:facebook_manage_pages => false)
    end
  end
  
  def check_data(user)
    # create an array of the facebook ids of all their friends
    friend_ids = @friends.inject([]) do |array, friend|
      array << friend["id"]
      array
    end
    
    # find all of their Facebook friends that are in our system
    new_friends = UserAuthentication.users_from_facebook_ids(friend_ids)
    
    # find all of their Facebook friends that they have followed before
    existing_friend_following = user.user_ids_following_from(new_friends)
    # existing_friend_followed_by = user.user_ids_followed_by(new_friends)
    
    # follow all friends in the system that have not been followed before
    new_friends.each do |new_friend|
      if !existing_friend_following.has_key?(new_friend[:id])
        handle_koala_oauth_error do
          current_user.following.create(:following => new_friend)
        end
      end
    end
    
    # create an array of the facebook ids of all the things they like
    like_ids = @likes.inject([]) do |array, like|
      array << like["id"]
      array
    end
    
    # find all the stores that they like on Facebook and that are in our system 
    new_likes = Store.stores_from_facebook_ids(like_ids)
    
    # find all the stores that they have followed before and are liked by them on Facebook
    existing_like_following = user.store_ids_following_from(new_likes)
    
    # follow those stores that it likes that it is not currently following
    new_likes.each do |store|
      if !existing_like_following.has_key?(store[:id])
        handle_koala_oauth_error do
          current_user.following.create(:following => store)
        end
      end
    end
  end
  
  def need_ssl? #!ENV['SERVER'].blank? or 
    !session[:need_to_close_with_https].blank? or (request.referer and request.referer.match(/^https:$/))
  end
  
  def close_window_redirect(do_render=false)
    puts "close_window_redirect"
    puts "request protocol is ssl? #{request.ssl?} (#{request.url})"
    if need_ssl? and !request.ssl?
      session[:need_to_close_with_https] = nil
      my_redirect = redirect_to :controller => "omniauth_callbacks", :action => "close_window", :protocol => 'https://'
      puts my_redirect
      my_redirect
    elsif do_render
      render :close_window, :layout => nil
    end
  end
  
  def close_window_ssl
    puts "close_window_ssl override"
    super if params[:action] != "close_window" and !request.fullpath.split("?")[0].match(/callback\/?$/)
  end
  
  def handle_koala_oauth_error(&block)
    begin
      yield
    rescue Koala::Facebook::APIError => e
      flash[:facebook] = "Your Facebook session expired. Please login with Facebook to update your friends on what you're doing."
    end
    #logout!
    #authorize_redirect
  end
end
