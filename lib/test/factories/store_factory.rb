FactoryGirl.define do
#  sequence :store_username do |n|
#    "aaaa#{rand(1000)}#{n}"
#  end
  
  factory :store do
    # associations:
#    username { FactoryGirl.build(:store_username) } if Spree::User.attribute_method? :username
#    taxon { FactoryGirl.build(:store_taxon_with_store) }
    taxon { FactoryGirl.build(:store_taxon) }
    
    trait :without_taxon do
      taxon nil
    end
    
    trait :tier do
      store_tier { FactoryGirl.create(:store_tier) }
    end
    
    trait :usa_epay_customer_number do
      usa_epay_customer_number '540907'
    end
    
    factory :store_without_taxon, :traits => [:without_taxon]
    factory :store_with_usa_epay, :traits => [:usa_epay_customer_number]
    factory :store_with_tier, :traits => [:tier]
    
    after(:create) do |store|      
      if store.taxon
        store.taxon.store = store
        store.taxon.save
      end
      brand = Brand.find_by_name("NOOKA")
      if brand.nil?
        brand = Brand.create(:name => "NOOKA")
        brand.save
      end
      store.brands << brand      
    end
  end
end
