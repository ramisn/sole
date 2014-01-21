Spree::UsersController.class_eval do
  layout 'account'
  before_filter :tag_ssl_page
  before_filter :load_object, :edit_profile
  before_filter :load_object, :change_picture
  before_filter :load_object, :authentications
    
  ssl_required
    
  def tag_ssl_page
	#Added by Brett to use for removing certain page elements during checkout process
	@ssl_page = true
  end
  
  def edit_profile
  end
  
  def update_profile
    # Now catching all FGraph::OAuth errors in the base controller, so this is unnecessary
    #begin
      if @user.facebook_auth and params[:from_facebook]
        handle_fgraph_oauth_error do
          extra_data = FGraph.me(:fields => "name,id,bio,gender,location,birthday,username", :access_token => @user.facebook_auth.access_token)
          
          updated_from_facebook = {}
          
          if params[:from_facebook][:name] and !extra_data['name'].blank?
            updated_from_facebook[:name] = extra_data['name']
          end
          if params[:from_facebook][:username] and !extra_data['username'].blank?
            updated_from_facebook[:username] = extra_data['username']
          end
          if params[:from_facebook][:current_city] and !(extra_data['location'].blank? || extra_data['location']['name'].blank?)
            updated_from_facebook[:current_city] = extra_data['location']['name']
          end
          if params[:from_facebook][:about] and !extra_data['bio'].blank?
            updated_from_facebook[:about] = extra_data['bio']
          end
          if params[:from_facebook][:gender] and !extra_data['gender'].blank?
            updated_from_facebook[:gender] = extra_data['gender'].capitalize
          end
          if params[:from_facebook][:birthday] and !extra_data['birthday'].blank?
            # properly parse the person's birthday
            birthday_parts = extra_data['birthday'].split('/')
            updated_from_facebook['birthday(1i)'] = birthday_parts[2]
            updated_from_facebook['birthday(2i)'] = birthday_parts[0]
            updated_from_facebook['birthday(3i)'] = birthday_parts[1]
            #birthday = Time.new(birthday_parts[2].to_i, birthday_parts[0].to_i, birthday_parts[1].to_i).to_date
            updated_from_facebook[:birthday] = birthday_parts
          end
          
          if params[:user].nil?
            params[:user] = {}
          end
          params[:user].merge!(updated_from_facebook)
        end
      end
      
      if @user.update_attributes(params[:user])
        flash[:success] = "Your profile has been updated."#I18n.t("profile_updated")
        redirect_to main_app.edit_profile_account_path
      else
        flash[:error] = "There was a problem saving your profile. Please try again."
        render :action => :edit_profile
      end
    #rescue FGraph::OAuthError => e
    #  logout!
    #end
  end
  
  def change_picture
  end
  
  def update_picture
    if @user.profile_image
      @user.profile_image = params[:user][:profile_image]
    else
      @user.profile_image.create(params[:user][:profile_image])
    end
    if @user.save
      flash[:success] = "Your profile picture has been updated."#I18n.t("profile_updated")
      redirect_to account_url
    else
      flash[:error] = "There was a problem saving your profile picture. Please try again."
      render :edit_profile
    end
  end
  
  def authentications
  end
  
end
