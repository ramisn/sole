module StoresHelper
  #
  # Returns the url of the person's social networking profile on the service
  # Expects to be sent a UserAuthentication object
  # Return example: http://facebook.com/ricaurte
  #
  def social_networking_url(store_auth)
    "http://"+case store_auth.provider
    when "facebook"
      "facebook.com/"
    when "twitter"
      "twitter.com/"
    else
      "soletron.com/"
    end+store_auth.nickname
  end
end
