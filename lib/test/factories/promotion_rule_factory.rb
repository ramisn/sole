FactoryGirl.define do
  factory :promotion_rule do
    promotion { FactoryGirl.create(:promotion, store: FactoryGirl.create(:store)) }
  end
  
  factory :store_total_promotion_rule, class: Spree::Promotion::Rules::StoreTotal do
    promotion { FactoryGirl.create(:promotion, store: FactoryGirl.create(:store)) }
    
    after(:build) do |promotion_rule|
      if promotion_rule.is_a?(Spree::Promotion::Rules::StoreTotal)
        promotion_rule.preferred_amount = 100.0
        promotion_rule.preferred_operator = 'gte'
      end
    end
  end
end
