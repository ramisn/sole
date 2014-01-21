module MembersHelper
  #
  # Returns the url of the person's social networking profile on the service
  # Expects to be sent a UserAuthentication object
  # Return example: http://facebook.com/ricaurte
  #
  def member_social_networking_url(user_auth)
    "http://"+case user_auth.provider
    when "facebook"
      "facebook.com/"
    when "twitter"
      "twitter.com/"
    else
      "soletron.com/"
    end+"#{(user_auth.nickname ? user_auth.nickname : user_auth.uid)}"
  end
end
