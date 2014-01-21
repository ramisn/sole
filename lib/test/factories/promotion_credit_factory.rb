FactoryGirl.define do
  factory :promotion_credit, class: "Spree::Adjustment" do
    adjustable { FactoryGirl.build(:order) }
    amount -10.00
    label 'Coupon (Jew10)'
    source { FactoryGirl.create(:promotion) }
    
    trait :free_shipping do
      source { FactoryGirl.create(:free_shipping_promotion) }
    end
    
    trait :store_buy_x_get_y do
      source { FactoryGirl.create(:buy_x_get_y_at_z_percent_off, store: FactoryGirl.build(:store)) }
    end
    
    trait :product_buy_x_get_y do
      source { FactoryGirl.create(:buy_x_get_y_at_z_percent_off, product: FactoryGirl.build(:product)) }
    end
    
    trait :store_flat_percent do
      source { FactoryGirl.create(:flat_percent, store: FactoryGirl.build(:store)) }
    end
    
    trait :store_flat_percent do
      source { FactoryGirl.create(:flat_percent, product: FactoryGirl.build(:product)) }
    end
    
    factory :free_shipping_promotion_credit, traits: [:free_shipping]
    
    #after(:create) do |promotion_credit|
    #  promotion_credit.source = FactoryGirl.create(:promotion)
    #  promotion_credit.save
    #end
  end
end
