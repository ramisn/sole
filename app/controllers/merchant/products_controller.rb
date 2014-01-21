class Merchant::ProductsController < Spree::Admin::ProductsController
  before_filter :authorized_store_member?

  before_filter :use_jquery_16
  
  before_filter :init
  create.before :create_before
  update.before :update_before

  layout "merchant"
 
  def upload_image
    if params[:qqfile].class == String
      file = StringIO.new(request.body.read) #mimic a real upload file
      file.class.class_eval { attr_accessor :original_filename, :content_type } #add attr's that paperclip needs
      file.original_filename = params[:qqfile] #assign filename in way that paperclip likes
      image = Spree::Image.create(:attachment => file)
    else
      image = Spree::Image.create(:attachment => params[:qqfile])
    end
    
    if params[:variant_id]
      variant = Spree::Variant.find(params[:variant_id])
      variant.images << image
    end
    render :text => {:id => image.id, :product_url => image.attachment.url(:product), :variant_id => params[:variant_id]}.to_json
  end
  
  def delete_images
    images = Spree::Image.find(params[:image_ids])
    images = [images] unless images.class == Array
    images.map(&:destroy)
    render :nothing => true
  end
  
  def delete_variants
    variants = Spree::Variant.find params[:variant_ids]
    variants.map(&:destroy)
    render :nothing => true
  end
  
  def destroy
    @product = Product.find_by_permalink!(params[:id])
    @product.update_attribute(:deleted_at, Time.now)

    @product.variants_including_master.update_all(:deleted_at => Time.now)

    if request.xhr?
      render :nothing => true
    else
      flash.notice = I18n.t('notice_messages.product_deleted')
      redirect_to :back
    end
  end
end