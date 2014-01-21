class FavoritesController < Spree::BaseController
  # load_resource :product, :only => [:create]
  load_resource :favorite, :only => [:destroy]
  before_filter :require_acting_as
  
  def create
    # TODO add to favorites broken, redirects to products_url
    if current_user and @acting_as == current_user
      @product = Spree::Product.find_by_id(params[:product_id])
      @favorite = current_user.favorites.create(:product => @product)
      
      @messages = {}
      if @favorite.errors.empty?
        @messages[:success] = "You successfully favorited #{@product.name}"
      else
        @messages[:error] = if request.xhr?
          errors = @favorite.errors.inject([]) do |array, (key, value)| 
            array << "#{key}: #{value.is_a?(Array) ? value.join('. ') : value}"
            array
          end.join(' ')
          "There was a problem when you tried to favorite #{@product.name}. #{errors}"
        else
          "There was a problem when you tried to favorite #{@product.name}."
        end
      end
      respond_to do |format|
        format.html do
          @messages.each do |key, value|
            flash[key] = value
          end
          if @favorite.errors.empty?
            redirect_to product_path(@product)
          else
            render :template => 'products/show'
          end
        end
        format.json { head :ok}
        format.js { head :ok}
      end
    end
  end
  
  def index
    @highlighting = :collection
    if params[:member_id]
      @user = Spree::User.find(params[:member_id])
    end
    if @user
      @parent = @user
      @favorites = @user.favorites.includes(:product)
      render :layout => 'members'
    else
      redirect_back_or_default(main_app.root_path)
    end
  end
  
  def destroy
    if @favorite.user == @acting_as
      @product = @favorite.product
      @favorite.destroy
      redirect_to product_path(@product)
    end
  end
  
  def remove_from_favorites
    @product = Spree::Product.find_by_id(params[:id])
    @favorite = current_user.favorites.find_by_product_id(@product.id)
    @favorite.destroy! if @favorite
    
    respond_to do |f|
      f.html {  redirect_to product_path(@product) }
      f.json { head :ok}
    end
  end
  
protected
  
  def require_acting_as
    unless @acting_as
      flash[:notice] = "You need to have an account in order to favorite a product."
      redirect_back_or_default('/')
    end
  end
  
end
