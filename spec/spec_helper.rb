# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require "paperclip/matchers"
## Can enable the following spree factories when upgraded to 0.70.0
#require 'spree/core/testing_support/factories'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/test/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  config.global_fixtures = :all
  
  config.include Paperclip::Shoulda::Matchers

  config.include Devise::TestHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller

  FactoryGirl.definition_file_paths = %w(lib/test/factories)
  FactoryGirl.find_definitions
end
ActiveRecord::Fixtures.create_fixtures("test/fixtures", ['spree_taxonomies', 'spree_taxons', 'spree_roles', 'spree_shipping_methods', 'spree_calculators', 'spree_promotion_rules', 'spree_preferences'])#, 'promotions'

## Allows for setting an admin user as the current user when accessing a controller as an admin
def set_admin(controller)
  @admin_user ||= FactoryGirl.create(:admin_user)
  
  controller.stub!(:authenticate).and_return(true)
  controller.stub!(:current_user).and_return(@admin_user)
end

## Allows for setting an admin user as the current user when accessing a controller as an admin
def set_merchant(controller)
  @merchant_user = FactoryGirl.create(:merchant_user)
  
  ###
  # Bug in FactoryGirl.create(:user) is giving user the admin role
  # for some reason the admin role is being added here, but I can't tell why...so this is patching it
  ###
  @merchant_user.stub!(:roles).and_return([Spree::Role.find_by_name('merchant')])
  @store = @merchant_user.stores.first
  controller.stub!(:authenticate).and_return(true)
  controller.stub!(:authorized_store_member?).and_return(true)
  controller.stub!(:current_user).and_return(@merchant_user)
end

def stub_and_return_association(item, association_name, method_to_stub_and_receive)
  temp = item.send(association_name)
  temp.stub!(method_to_stub_and_receive)
  temp.should_receive(method_to_stub_and_receive)
  item.stub!(association_name).and_return(temp)
  item
end

