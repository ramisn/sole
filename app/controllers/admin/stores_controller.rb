class Admin::StoresController < Spree::Admin::ResourceController
  include ResourceControllerOverrides

  create.before :create_before
  update.before :update_before
  destroy.before :destroy_before
  before_filter :set_fullsize

  def index
    respond_with(@collection) do |format|
      format.html
      format.json { render :json => json_data }
    end
  end
  
  def destroy_before
    store = Store.find(params[:id])
    puts "**** before destroying Store #{store.taxon.name}, deleting its #{store.taxon.products.size} products"
    Spree::Product.where(:id => store.taxon.products).update_all(:deleted_at => Time.now)
    Spree::Taxon.destroy(store.taxon)
  end

  def destroy_before
    store = Store.find(params[:id])
    puts "**** before destroying Store #{store.taxon.name}, deleting its #{store.taxon.products.size} products"
    Spree::Product.where(:id => store.taxon.products).update_all(:deleted_at => Time.now)
    Spree::Taxon.destroy(store.taxon)
  end

  def collection
    return @collection if @collection.present?

    unless request.xhr?
      @search = Store.metasearch(params[:search])
      @collection = @search.page(params[:page]).per(Spree::Config[:admin_products_per_page])
    else
      @collection = super.where((["name #{LIKE} ?", "%#{params[:q]}%"]))
    end
  end

  def create_before
    manager = Spree::User.find_by_email(params[:manager][:email])
    if manager.nil?
      flash[:error] = "An error has occurred while creating the store - Please provide an email address for a valid user"
    else
      taxonomy = Spree::Taxonomy.find_by_name("Stores")
      @taxon = taxonomy.taxons.build(:name => params[:taxon][:name])
      @taxon.parent_id = Spree::Taxon.find_by_name("Stores").id

      Spree::Config[:default_product_groups].split(',').each do |name|
        Spree::ProductGroup.create!(:name => name)
      end

      unless params[:store][:brands_list].nil?
        add_to_brands(params[:store][:brands_list])
        params[:store].delete(params[:store][:brands_list])
      end

      if @taxon.save
        @object.taxon = @taxon
        if !manager.has_role?(:merchant)
          manager.roles << Spree::Role.find_by_name(:merchant)
        end
        @object.users << manager
      else
        flash[:error] = I18n.t('errors.messages.could_not_create_taxon')
      end
    end
  end

  def update_before
    unless params[:store][:brands_list].nil?
      add_to_brands(params[:store][:brands_list])
      params[:store].delete(params[:store][:brands_list])
    end
  end

  protected

  def set_fullsize
    @fullsize = false
  end

  def add_to_brands(brands_list)
      puts "the brands submitted are: #{brands_list}"
      brands = brands_list.split(',')
      @store.brands = []
      brands.each do |b|
        b.strip!
        brand = Brand.find_by_name(b)
        if brand.nil?
          brand = Brand.create(:name => b)
        end
        @store.brands << brand
      end
      @store.brands.uniq!
  end
end
