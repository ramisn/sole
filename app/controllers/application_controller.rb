require 'model_request_info'

class ApplicationController < ActionController::Base
  protect_from_forgery 

  include ModelRequestInfo
  include AuthenticateHelper
  
  before_filter :set_request_for_models
  before_filter :set_acting_as
  

  def not_found
    if /(jpe?g|png|gif)/i === request.path
      render :text => "404 Not Found", :status => 404
    else
      render :template => "shared/404", :layout => '/spree/layouts/spree_application', :status => 404
    end
  end
  
  protected
  
  def set_acting_as
     # Find the entity the user is acting on behalf of, them self or a store
     if session["acting_as_store"].is_a?(Fixnum)
       @acting_as = Store.find(session["acting_as_store"])
     end

     if @acting_as.nil?
       session["acting_as_store"] = nil
       @acting_as = current_user
     end
     puts @acting_as.inspect
  end
 
  def require_login
    if !current_user
      flash[:error] = "You do not have access to Soletron yet.  Please visit http://soletron to learn more about what we're doing."
      logout!
    end
  end

  

  
end
