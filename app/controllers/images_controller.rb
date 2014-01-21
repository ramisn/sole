class ImagesController < Spree::BaseController
  before_filter :require_current_user
  before_filter :require_product
  
  def new
    @image = @product.images.new
  end
  
  def edit
    @image = @product.images.find(params[:id])
  end
  
  def index
    @images = @product.images
  end
  
  protected
  
  def require_current_user
    unless current_user
      store_location
      flash[:error] = "You need to login to add images to products"
      redirect_to login_path
    end
  end
  
  def require_product
    unless @product = current_user.products.find(params[:product_id])
      flash[:error] = "The product you were looking to edit could not be found."
      redirect_to main_app.root_path
    end
  end
end
