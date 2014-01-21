Given /I am a merchant of "(.+)"/ do |store_name|
  merchant = Spree::User.find_by_email!("merchant@example.com")
  store = Store.includes(:taxon).where(:taxons => {:name => store_name}).limit(1).first
  merchant.stores << store
  step %{a store "Store" should exist with id: #{store.id}}
end
