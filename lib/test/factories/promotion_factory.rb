FactoryGirl.define do
  factory :promotion, class: Spree::Promotion do
    name 'SoleDiscount'
    code 'Jew10'
    #association :calculator, factory: :calculator
    
    trait :free_shipping do
      code 'Yo dude'
      #association :calculator, factory: :free_shipping_calculator
      after(:create) do |promotion|
        promotion.promotion_actions << FactoryGirl.create(:free_shipping_create_adjustment, promotion: promotion)
      end
    end
    
    trait :product do
      product { FactoryGirl.build(:product) }
    end
    
    trait :store do
      store { FactoryGirl.build(:store) }
    end
    
    trait :flat_percent do
      #association :calculator, factory: :flat_percent_calculator
      after(:create) do |promotion|
        puts "created promotion"
        promotion.promotion_actions << FactoryGirl.build(:flat_percent_create_adjustment, promotion: promotion)
        puts "added promotion action"
      end
    end
    
    trait :automatic do
      code ""
    end
    
    factory :free_shipping_promotion, traits: [:free_shipping]
    factory :product_promotion, traits: [:product]
    factory :store_promotion, traits: [:store]
    factory :flat_percent_promotion, traits: [:flat_percent]
    factory :flat_percent_automatic_promotion, traits: [:flat_percent, :automatic]
    
    after(:create) do |promotion|
      #promotion.calculator.calculable = promotion
      #promotion.calculator.save
    end
  end
end
