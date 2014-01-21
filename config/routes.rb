Soletronspree::Application.routes.draw do

  mount Spree::Core::Engine, :at => '/'

  get "google/us_products"
  
  get "error/message_400"
  
  get "error/message_404"
  
  get "error/message_422"
  
  get "error/message_500"
  
  get "error/message_503"
  
  get "disabled/checkout"
  
  # match '/cart' => "Disabled#cart"
  # match '/checkout' => "Disabled#cart"
  
  get "disabled/cart"
  
  get "homepage/index"
  get "products/best_seller" #for the best product selection 
  get "products/most_popular" #for the most popular seller selection
  
  match 'merchant' => redirect("/merchant/store")

  match '/checkout/registration' => 'checkout#registration', :via => :get, :as => :checkout_registration
  match '/checkout/registration' => 'checkout#update_registration', :via => :put, :as => :update_checkout_registration
  match '/checkout/guest_confirmation', :to => 'checkout#guest_confirmation', :via => :get, :as => :guest_confirmation

  match '/order/:confirmation_token' => 'spree/orders#checkout_confirmation', :as => :checkout_confirmation
  match '/order/remove_item/:id' => 'spree/orders#remove_item', :as => :remove_item
  match '/order/generate_pdf/:id' => 'spree/orders#generate_pdf'
  match '/sort_filter/:id' => 'spree/products#sort_filter'
  match '/send_email_to_followers/:id' => 'merchant/products#send_email_to_followers'


  match '/auth/popup' => 'auth#popup'
  
  get 'brands', :action => :index, :controller => :stores
  
 
  match '/products/:id/unfav' => 'favorites#remove_from_favorites', :as => :remove_product_from_favorites

  
  # devise_for :users, :controllers => { :registrations => "users/registrations" }, :only => :new
  namespace :merchant do
    
    resources :store do
      resource :profile_image
      resource :banner_image
      member do
        get :facebook_page
        put :update_facebook_page
        put :update_profile
      end
      resources :products do
        resources :variants do
          collection do
            post :update_positions
          end
        end
        resources :images do
          collection do
            post :update_positions
          end
        end
        member do
          get :clone
          put :publish
          put :feature
        end
        collection do
          post :preview
          put :preview
          delete :delete_variants
        end
      end
      resources :orders do
        member do
          put :ship
          get :cancel
          get :cancel_item
          get :confirm_cancel_remaining
          put :cancel_remaining
          get :confirm_force_cancel
          put :force_cancel
        end
      end
      resources :inventory_units, :only => [] do
        member do
          get 'confirm_cancel'
          put 'cancel'
          get 'confirm_force_cancel'
          put 'force_cancel'
        end
      end
      resources :vendor_payment_periods, :only => [:show, :index] do
        member do
          get :line_items_data
          get :shipping_data
          get :coupons_data
        end
      end
      resources :vendor_payments, :only => [:index]
      resources :promotions do
        resources :promotion_rules
      end
    end
    resources :store_admin, :only => [:edit, :create, :destroy]
  end
  
  scope :module => 'spree' do
    resource :account, :controller => "users" do
      member do
        get 'edit_profile'
        put 'update_profile'
      end
      collection do
        get 'authentications'
      end

      #resources :feedbacks, :only => [:index, :needed]
      match 'update_profile' => redirect("/account/edit_profile")
    end
  end
  
  resources :members, :only => [:show, :index] do
    member do
      get 'about'
      get 'followers'
      get 'following'
    end
    
    resource :follow, :only => [:create, :destroy]
    
    match 'follow' => redirect { |params| "/members/#{params[:member_id]}" }
    get 'page/:page', :action => :index, :on => :collection
    
    resource :feed, :only => [:show] do
      member do
        get 'network'
        get 'all'
        get 'feed'
      end
    end
    
    resource :shoutout, :only => [:create]
    resource :collection, :only => [:show] do
      member do
        get 'purchases'
        #get 'shopping_cart'
        get 'favorites'
        get 'uploaded'
      end
    end
    #resources :favorites, :only => [:index]
    resources :feedbacks do
      collection do
        get 'needed'
      end
    end
    resources :feed_items, :only => [:show, :destroy] do
      resources :comments, :only => [:create]
    end
  end
  resource :members


  
  resources :stores, :only => [:show, :index] do
    member do
      get 'about'
      get 'followers'
      get 'following'
      get 'store'
      get 'policies'
    end
    
    resource :follow, :only => [:create, :destroy]
    match 'follow' => redirect { |params| "/members/#{params[:member_id]}" }
    resource :feed, :only => [:show] do
      member do
        get 'network'
        get 'all'
        get 'feed'
      end
    end
    resource :shoutout, :only => [:create]
    #resources :feedbacks, :only => [:index] do
    #  collection do
    #    get 'needed'
    #  end
    #end
  end
  
  resources :feed_items, :only => [:show, :destroy] do
    resources :comments, :only => [:create]
  end
 
  resource :notifications, :only => [:show]
    
  resources :comments, :only => [:destroy]
    
  devise_scope :user do
    match '/close_window' => "omniauth_callbacks#close_window"
  end
    
  resources :products do
    resource :favorite, :only => [:create]
    collection do
      get 'menu'
    end
    member do
      get :preview
    end
  end
  
  resources :user_products, :except => [:show]
  #resources :feedbacks, :only => [:edit, :update, :destroy]
  resources :favorites, :only => [:destroy]
  
  resources :redirects, :only => [:index]
  
  get 'search' => 'search#index'
  get 'search/stores' => 'stores#index', :kind => 'store'
  get 'search/members' => 'members#index', :kind => 'member'
  post "/merchant/products/upload_image" => "merchant/products#upload_image", :as => :upload_image_for_product
  delete "/merchant/products/delete_images" => "merchant/products#delete_images", :as => :delete_product_image
  # If we puts profile_image as resource inside spree/account, then it will raise uninitialize Spree::ProfileImagesController error.
  get "/account/profile_image" => "profile_images#show", :as => :account_profile_image
  get "/account/profile_image/new" => "profile_images#new", :as => :new_account_profile_image
  get "/account/profile_image/edit" => "profile_images#edit", :as => :edit_account_profile_image
  post "/account/profile_image" => "profile_images#create"
  put "/account/profile_image" => "profile_images#update"
  delete "/account/profile_image" => "profile_images#destroy"
   
   namespace :admin do
     resources :line_items
     resources :stores
     resources :store_tiers
     resources :users do
       resources :taxons do
         member do
           get :selectuser
           delete :removeuser
         end
         collection do
           post :availabletouser
         end
       end
     end
     resources :taxons do
       member do
         put :update_profile
         put :update_facebook_page
       end
     end
     resources :payments do
       member do
         get :new_refund
         post :create_refund
       end
       collection do
         get :refunds_payable
         get :refunds_paid
       end
     end
     resources :orders do
       member do
         get :confirm_force_cancel
         get :generate_pdf
         put :force_cancel
       end
       resources :payments do
         collection do
           get :new_refund
           post :create_refund
         end
       end
     end
     resources :vendor_payment_periods, :only => [:index, :show] do
       resources :vendor_payments, :only => [:new, :create] do
         collection do
           get :new_chargeback
           put :create_chargeback
         end
       end
     end
     resources :vendor_payments, :only => [:index, :show] do
       collection do
         get :reversed
       end
     end
   end
   
   
   ####
   # From spree_social gem, because it's not included as part of the gemspec paths
   ####
   
   # We need to be tricky here or Devise loads up the defaults again.



  scope :module => 'spree' do
    devise_for  :user_authentications, 
                 :class_name => 'Spree::UserAuthentication',
                 :skip => [:registrations, :unlocks],
                 :controllers => {:passwords => "user_passwords",
                                   :sessions => "user_sessions",
                                   :omniauth_callbacks => "omniauth_callbacks" }   do
         post "merge", :to => "user_sessions#merge", :as => "merge_user"
         match '/confirmation/:confirmation_token' => 'user_sessions#confirmation', :as => :confirmation
      end
    resources :user_authentications 
    
    match 'account' => '/spree/users#show', :as => 'user_root'
  end 
  

   
  
   
  namespace :admin do
    resources :authentication_methods
  end
   
  resource :view_apis, :only => [:header] do
    member do
      get :header
    end
  end
  
  root :to => 'products#index'
end
