class ViewApisController < Spree::BaseController
  def header
    @acting_as = current_user
    render :partial => "shared/nav_bar", :layout => false
  end
end