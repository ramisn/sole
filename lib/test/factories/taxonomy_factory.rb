FactoryGirl.define do
  factory :taxonomy, class: Spree::Taxonomy do
    name 'Brand'
  end
  
  # added for soletron
  factory :store_taxonomy, :parent => :taxonomy do
    name 'Stores'
  end
  
  # added for soletron
  factory :categories_taxonomy, :parent => :taxonomy do
    name 'Categories'
  end
end
