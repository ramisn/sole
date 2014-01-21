# Overriding in order to set default permissions to what Soletron needs, 
# allow for adding new permissions (manage_pages case for merchants), 
# and also make the display be for a popup
OmniAuth::Strategies::Facebook.class_eval do 
  def request_phase
    options[:scope] ||= "email,publish_stream,user_likes,user_about_me,user_birthday,user_location"
    if request.params['add_scope']
      options[:scope] += ",#{request.params['add_scope']}"
    end
    if request.params['display']
      options[:display] = request.params['display']
    end
    session['omniauth.facebook.display'] = request.params['display']
    super
  end      
end   
