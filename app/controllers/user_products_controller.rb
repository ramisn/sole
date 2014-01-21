class UserProductsController < Spree::BaseController
  # for field_container

  helper '/spree/admin/base'

  layout 'members', :only => [:new, :edit]
  before_filter :require_current_user
  before_filter :require_user_product, :only => [:show, :edit, :update, :destroy]
  
  def new
    @user = current_user
    @product = current_user.uploaded_products.new
    @product.options.build(:option_type => Spree::OptionType.find_by_name('color1'))
    @product.options.build(:option_type => Spree::OptionType.find_by_name('color2'))
    @product.images.build
  end
  
  def create
    @user = current_user
    params[:user_product][:sku] = 1
    @product = current_user.uploaded_products.create(params[:user_product])
    @product.options.build(:option_type => Spree::OptionType.find_by_name('color1'))
    @product.options.build(:option_type => Spree::OptionType.find_by_name('color2'))
    @product.master.option_values << Spree::OptionValue.find(params[:variant_data]['0']['Primary Color'])
    @product.master.option_values << Spree::OptionValue.find(params[:variant_data]['0']['Secondary Color'])
    @product.save()
    if @product.errors.empty?
      flash[:success] = "Your product has been saved."
      redirect_to uploaded_member_collection_path(@product.user)
    else
      flash[:error] = "There were errors when trying to save your product."
      render :new
    end
  end
  
  def show
    render :template => '/spree/products/show'
  end
  
  def edit
    
  end
  
  def update
    @user = current_user
    @product.update_attributes(params[:user_product])
    @product.master.option_values = []
    @product.master.option_values << Spree::OptionValue.find(params[:variant_data]['0']['Primary Color'])
    @product.master.option_values << Spree::OptionValue.find(params[:variant_data]['0']['Secondary Color'])
    @product.save()
    if @product.errors.empty?
      flash[:success] = "Your product has been saved."
      redirect_to uploaded_member_collection_path(@product.user)
    else
      flash[:error] = "There were errors when trying to save your product."
      render :edit
    end
  end
  
  def destroy
    @product.deleted_at = Time.now
    if @product.save
      flash[:success] = "Your product has been deleted."
    else
      flash[:error] = "There were errors when trying to delete your product."
    end
    redirect_back_or_default uploaded_member_collection_path(@product.user)
  end
  
  protected
  
  def require_current_user
    unless current_user
      flash[:error] = "You need to login in order to upload products"
      redirect_to login_path
    end
  end
  
  def require_user_product
    unless @product = current_user.uploaded_products.find(params[:id])
      flash[:error] = "The user product you were looking for could not be found."
      redirect_back_or_default(main_app.root_path)
    end
  end
  
  def require_owner
    unless current_user != @product.user
      flash[:error] = "You need to be the owner to modify a product"
      redirect_back_or_default(member_collection_path(@product.user))
    end
  end
end
