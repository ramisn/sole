Spree::Admin::BaseController.class_eval do
  
  def authorize_admin
    authorize!(:admin, Object)
    rescue # trap authorization failure for merchant panel
    authorize!(:manage, self.class)
  end
  
  def set_fullsize
    @fullsize = true
    @hide_store_nav = true
  end
  
  def use_jquery_16
    @jquery_16 = true
  end

end
