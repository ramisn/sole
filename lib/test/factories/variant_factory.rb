FactoryGirl.define do
  factory :variant, class: Spree::Variant do
    price 19.99
    cost_price 17.00
    sku    { Faker::Lorem.sentence }
    weight { BigDecimal.new("#{rand(200)}.#{rand(99)}") }
    height { BigDecimal.new("#{rand(200)}.#{rand(99)}") }
    width  { BigDecimal.new("#{rand(200)}.#{rand(99)}") }
    depth  { BigDecimal.new("#{rand(200)}.#{rand(99)}") }

    # associations:
    product { |p| p.association(:product) }
    
    after(:create) do |variant|      
      variant.option_values << FactoryGirl.build(:option_value)
      variant.save
    end
    
    trait :on_sale do
      sale_price 5.00
    end
    
    factory :on_sale_variant, traits: [:on_sale]
  end
end
