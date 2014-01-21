FactoryGirl.define do
  sequence(:product_sequence) { |n| "Product ##{n} - #{rand(9999)}" }

  factory :product, class: Spree::Product do
    name { FactoryGirl.generate :product_sequence }
    description { Faker::Lorem.paragraphs(rand(5)+1).join("\n") }

    # associations:
    #association(:tax_category)
    association(:shipping_category)
    
    price 19.99
    cost_price 17.00
    sku 'ABC'
    available_on 1.year.ago
    deleted_at nil
    association(:brand)
    
    after(:build) do |p|
      puts "after building product"
    end
    
    # added for soletron
    after(:create) do |product| 
      puts "after creating product"
      if product.taxons.size == 0
        product.taxons << FactoryGirl.create(:store_taxon_with_store)
        product.taxons << FactoryGirl.create(:category_taxon_with_parent_with_commission)
        product.save
      end
    end
  end

  factory :product_with_option_types, :parent => :product do
    after(:create) { |product| FactoryGirl.create(:product_option_type, :product => product) }
  end
  
  factory :published_product, :parent => :product do
    state 'published'
  end
end
