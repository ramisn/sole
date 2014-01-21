class AuthController < Spree::BaseController
  # for sending the authentication form popup to other sites
  def popup
    render :partial => '/shared/nav_bar', :template => false
  end
end
