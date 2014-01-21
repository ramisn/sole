# NOTE / FIXME a bunch of Spree meta magic was destroy because this controller
# was named signular StoreController when it should have been named
# StoresController to fit the Spree idiom.
class Merchant::StoreController < Spree::Admin::ResourceController

  layout 'merchant'
  helper Spree::Admin::NavigationHelper

  before_filter :authorized_store_member?, :only => [:show, :edit, :facebook_page, :update, :update_profile, :update_facebook_page, :delete]
  before_filter :load_stores, :only => [:index]
  before_filter :load_store, :only => [:show, :edit, :facebook_page, :update, :update_profile, :update_facebook_page, :delete]

  def index
    @store = @stores.first
  end

  def edit
    @title = @store.name_from_taxon + " | Company Name & Info"
    @states = Spree::State.all(:order => "name ASC")
  end

  def show
    @products = @store.taxon.products.includes( :variants => [:images, :option_values]).page(params[:page]).per(Spree::Config[:admin_products_per_page])
 
    @search = Spree::Product.metasearch(params[:search])

    respond_with(@products) do |format|
      format.html { render :layout => !request.xhr? }
      format.js { render :layout => false }
    end
  end

  def facebook_page
    # Now catching all FGraph::OAuth errors in the base controller, so this is unnecessary
    begin
      if current_user.facebook_auth
        @pages = FGraph.me('accounts', :access_token => current_user.facebook_auth.access_token)
      end
    rescue FGraph::OAuthError => e
      #      flash[:error] = "You must login ### with Facebook before you can modify the Facebook credentials on this page."
      @not_logged_in_with_facebook = true
    end
  end

  def update_profile    
    puts "**** updating profile; permalink is #{params[:permalink]}"
    if (!params[:permalink].blank? && (params[:permalink] != @store.username))
      puts "**** setting permalink"
      @store.set_username(params[:permalink])
    elsif (!params[:taxon].blank? && !params[:taxon][:name].blank? && (params[:taxon][:name] != @store.taxon.name))
      puts "**** setting permalink to new store name"
      @store.set_username(params[:taxon][:name])
    end
    # Now catching all FGraph::OAuth errors in the base controller, so this is unnecessary
    begin
      manager = @store.managers.find_by_user_id(current_user)
      if manager and manager.facebook_access_token and params[:from_facebook]
        handle_fgraph_oauth_error do
          extra_data = FGraph.object(@store.facebook_id, :access_token => manager.facebook_access_token)
          updated_from_facebook = {}
          updated_from_facebook_taxon = {}

          if params[:from_facebook][:name] and !extra_data['name'].blank?
            updated_from_facebook_taxon[:name] = extra_data['name']
          end
          if params[:from_facebook][:email] and !extra_data['email'].blank?
            updated_from_facebook[:email] = extra_data['email']
          end
          if params[:from_facebook][:location] and !extra_data['location'].blank?
            updated_from_facebook[:location] = "#{extra_data['location']['city']}, #{extra_data['location']['state']}"
          end
          if params[:from_facebook][:founded] and !extra_data['founded'].blank?
            updated_from_facebook[:founded] = extra_data['founded']
          end
          if params[:from_facebook][:about] and !extra_data['about'].blank?
            updated_from_facebook[:about] = extra_data['about']
          end
          if params[:from_facebook][:company_overview] and !extra_data['company_overview'].blank?
            updated_from_facebook[:company_overview] = extra_data['company_overview']
          end
          if params[:from_facebook][:mission] and !extra_data['mission'].blank?
            updated_from_facebook[:mission] = extra_data['mission']
          end
          if params[:from_facebook][:description] and !extra_data['description'].blank?
            updated_from_facebook[:description] = extra_data['description']
          end
          if params[:from_facebook][:product_types] and !extra_data['products'].blank?
            updated_from_facebook[:product_types] = extra_data['products']
          end

          if params[:store].nil?
            params[:store] = {}
          end
          if params[:taxon].nil?
            params[:taxon] = {}
          end

          params[:store].merge!(updated_from_facebook)
          params[:taxon].merge!(updated_from_facebook_taxon)
        end
      end

      if @store.update_attributes(params[:store]) and @store.taxon.update_attributes(params[:taxon])
        flash[:success] = "Your Store has been updated."#I18n.t("profile_updated")
        redirect_to main_app.edit_merchant_store_path(@store)
      else
        flash[:error] = "There was a problem saving your store. Please try again."
        render :edit
      end
    rescue FGraph::OAuthError => e
      flash[:error] = "You must login with Facebook before you can modify the Facebook credentials on this page."
      @not_logged_in_with_facebook = true
      render :edit
    end
  end

  def update_facebook_page
    if params[:store] and params[:store][:facebook_id]
      # Now catching all FGraph::OAuth errors in the base controller, so this is unnecessary
      handle_fgraph_oauth_error do
        # access all of the pages that a person manages on Facebook
        pages = FGraph.me('accounts', :fields => "access_token,id,name,link", :access_token => current_user.facebook_auth.access_token)
        page = nil

        # find the page with an id equal to the facebook_id sent by the form
        pages.each do |p|
          if p['id'] == params[:store][:facebook_id]
            page = p
          end
        end

        # access_token needs to be retained, but isn't valid for a Store
        access_token = page.delete('access_token')

        # this is the data need to update the store
        soletron_page = { :facebook_id => page['id'], :facebook_name => page['name'], :facebook_link => page['link'] }

        # update id, name, link for store
        if @store.update_attributes(soletron_page)
          manager = @store.managers.find_by_user_id(current_user)
          # apply the access_token to the store, so that the user can submit data to the facebook page
          manager.update_attributes(:facebook_access_token => access_token, :facebook_manager => true)
          flash[:success] = "Your Store has now been successfully linked to your Facebook Page."#I18n.t("profile_updated")
          redirect_to main_app.merchant_store_path(@store.id)
        else
          if current_user.facebook_auth
            @pages = FGraph.me('accounts', :access_token => current_user.facebook_auth.access_token)
          end
          flash[:error] = "There was a problem linking your facebook page. Please try again."
          render :facebook_page
        end
        #rescue FGraph::OAuthError => e
        #  flash[:error] = "Please login again, because your Facebook session expired."
        #  logout!
      end
    else
      if current_user.facebook_auth
        handle_fgraph_oauth_error do
          @pages = FGraph.me('accounts', :access_token => current_user.facebook_auth.access_token)
        end
      end
      flash[:error] = "You did not select a facebook page."
      render :facebook_page
    end
  end

  protected

  def load_store
    @store = Store.find(params[:store_id] || params[:id])
  end

  def load_stores
    if current_user.admin?
      @stores = @store = Store.all
    else
      @stores = @store = current_user.stores
    end
  end

end
