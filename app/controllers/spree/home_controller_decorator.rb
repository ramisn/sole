Spree::HomeController.class_eval do 
  
  def index
    redirect_to spree.products_url
  end
end