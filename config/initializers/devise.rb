# From spree_social gem
Devise.setup do |config|

  config.confirm_within = 0
  config.authentication_keys = [ :login ]   # allow logins with username

  SpreeSocial::OAUTH_PROVIDERS.each do |provider|
    SpreeSocial.init_provider(provider[1])
  end

end


module Devise::Controllers::InternalHelpers
  # override devise-1.3.3/lib/devise/controllers/internal_helpers.rb
  # from printing verbose already logged in message
  def require_no_authentication
    if warden.authenticated?(resource_name)
      resource = warden.user(resource_name)
      #flash[:alert] = I18n.t("devise.failure.already_authenticated")
      redirect_to after_sign_in_path_for(resource)
    end
  end
end

