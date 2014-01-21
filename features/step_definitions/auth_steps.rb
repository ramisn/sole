Given /^I am an admin$/ do
  admin = FactoryGirl.create(:admin_user)
  step %{I am on the login page}
  step %{I fill in the following within "#signin-form":}, table(%{
    | user[login] | #{admin.email} |
    | user[password] | #{FactoryGirl.attributes_for(:admin_user)[:password]} |
  })
  step %{I press "log on"}
  step %{I should be on the account page}
end

Given /^I am a merchant$/ do
  step %{a merchant user: "Merchant" exists with email: "merchant@example.com"}
  merchant = Spree::User.find_by_email!("merchant@example.com")

  #puts "merchant is #{merchant.inspect}"
  store = merchant.stores.first
  #puts "store is #{store.inspect}"

  step %{a store: "Store" should exist with id: #{store.id}, username: "#{store.username}"}

  #store_found = find_model!("store \"Store\"")
  #puts "store found is #{store_found.inspect}"
  #puts " merchants #{store_found.managers}"
  #merchant = FactoryGirl.create(:merchant_user)

  step %{I am on the login page}
  step %{I fill in the following within "#signin-form":}, table(%{
    | user[login] | merchant@example.com |
    | user[password] | #{FactoryGirl.attributes_for(:merchant_user)[:password]} |
  })
  step %{I press "log on"}
  step %{I should be on the account page}
end

When /^I log in as a user$/ do
  user = FactoryGirl.create(:user)
  step %{I am on the home page}
  step %{I fill in the following within "#signin-form":}, table(%{
    | user[login] | #{user.email} |
    | user[password] | #{FactoryGirl.attributes_for(:user)[:password]} |
  })
  step %{I press "log on"}
  step %{I should be on the account page}
end