FactoryGirl.define do
  factory :promotion_create_adjustment, class: Spree::Promotion::Actions::CreateAdjustment do
    #promotion { puts "adding promotion to create adjustment"; FactoryGirl.build(:promotion) }
    calculator { FactoryGirl.build(:calculator) }
    
    trait :flat_percent_calculator do
      calculator { puts "adding flat percent calculator"; FactoryGirl.build(:flat_percent_calculator) } 
    end
    
    factory :flat_percent_create_adjustment, traits: [:flat_percent_calculator]
  end
end
