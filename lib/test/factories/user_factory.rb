FactoryGirl.define do
  sequence :user_authentication_token do |n|
    "xxxx#{Time.now.to_i}#{rand(1000)}#{n}xxxxxxxxxxxxx"
  end
  
  sequence :user_username do |n|
    "blah-#{rand(1000000)}-#{n}"
  end
  
  ###
  # BUG
  # For some reason FactoryGirl.create(:user) in set_merchant in spec_helper.rb is adding the admin role to
  # the user, including for merchants.
  ###
  factory :user, class: Spree::User do
    email { Faker::Internet.email }
    login { email }
    password 'secret'
    password_confirmation 'secret'
    authentication_token { FactoryGirl.generate(:user_authentication_token) } if Spree::User.attribute_method? :authentication_token
    confirmed_at Time.now.utc
    username { FactoryGirl.generate(:user_username) }
    birthday { 25.years.ago }
    roles {[]}
  end

  factory :admin_user, :parent => :user do
    roles { [Spree::Role.find_by_name('admin') || FactoryGirl.create(:role, :name => 'admin')]}
  end
  
  factory :merchant_user, :parent => :user do
    roles { [Spree::Role.find_by_name('merchant') || FactoryGirl.create(:role, :name => 'merchant')]}
    stores { [FactoryGirl.create(:store_with_usa_epay)] }
  end
end
