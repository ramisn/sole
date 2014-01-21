class SearchController < Spree::BaseController
  include Spree::BaseHelper
  
  layout '/spree/spree_application'
  
  def index
    # @search   = Search.new(params[:kind], params[:q])
    # @results  = @search.results
    # raise @results.inspect
    case params[:kind]
    when 'member'
      redirect_to main_app.members_path, :q => params[:q]
      
     when 'store'
       redirect_to main_app.stores_path, :q => params[:q]
       # @stores = @results.page(paginate_opts[:page]).per(paginate_opts[:per_page])
       #        @stores_followers = Follow.followers_count(@stores)
       # 
       #        render :action => '/stores/index'
     when 'product'
       #--
       # Temporarily we do redirect, using _search partial, to the
       # products controller. It means that this code should not be
       # executed, yet.
       #++
       render :nothing => true
     else
       render :nothing => true
     end
  end
  
  protected
    #--
    # Please note that we use Spree::Config[:products_per_page] for members,
    # and stores.
    #++
    def paginate_opts
      ({}).tap do |ret|
        ret[:per_page] = Spree::Config[:products_per_page]
        ret[:page] = params[:page]
      end
    end
end
