class Merchant::StoreSettingsController < ApplicationController
  layout 'spree_application'
  before_filter :authorized_store_member?, :only => [:show, :edit, :update, :delete]
end
