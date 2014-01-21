class StoresUser < ActiveRecord::Base
  belongs_to :store
  belongs_to :user, :class_name => "Spree::User"
  set_primary_keys :user_id, :store_id  
  
  ###
  # Facebook provides access access tokens for managing pages for each user, so a StoresUser
  # model is necessary in order to save the access_tokens for each user and each Facebook page
  # they manage.
  ###
  
  def facebook_manager?
    self.facebook_manager
  end
end