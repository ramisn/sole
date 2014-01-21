FactoryGirl.define do
  factory :line_item_promotion_credit do
    line_item { FactoryGirl.build(:open_line_item, quantity: 4) }
    promotion_credit { FactoryGirl.create(:promotion_credit) }
    quantity 2
    
    trait :free_shipping do
      promotion_credit { FactoryGirl.create(:free_shipping_promotion_credit) }
      quantity 1
    end
    
    factory :free_shipping_line_item_promotion_credit, :traits => [:free_shipping]
    
  end
end

