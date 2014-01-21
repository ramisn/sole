class Merchant::ImagesController < Spree::Admin::ImagesController
  before_filter :authorized_store_member?
  before_filter :product_belongs_to_store?

  before_filter :load_data
  before_filter :load_store
  before_filter :show_flash, :only => [:index]
  before_filter :update_status, :only => [:index]

  # need to get the callbacks from the base class - can we do this programatically?
  create.before :set_viewable
  update.before :set_viewable
  destroy.before :destroy_before

  create.after :set_image_version

  layout "merchant"

  def destroy
    puts "**** destroying image #{@image.id} from product #{@image.viewable}"
    product = nil
    image_id = @image.id
    if @image.viewable.is_a?(Spree::Product)
      product = @image.viewable
    end
    super
    if !product.nil?
      product = product.root_product
      if product.featured_image_id == image_id     # did we just delete the featured product image?
        product.featured_image_id = -1
        product.find_image_to_feature
        product.save
      end
    end
  end
  
  protected
  
  def load_store
    @store = Store.find(params[:store_id])
  end

  def show_flash
#    if @updating
#      flash[:notice] = t(:edit_message)
#    end
    puts "**** need to show flash message here"
  end

  def update_status
    if !@product.present?
      @product = Spree::Product.find_by_id(params[:product_id])
    end
    unless @product.nil?
      @product.get_siblings.each do |product|
        product.add_skus if product.draft?
      end
    end
  end

  def set_image_version
    @image.version = 1
    @image.save
  end

  private
  
  def location_after_save
    merchant_store_product_images_url(@store, params[:product_id])
  end
end
