FactoryGirl.define do
  factory :taxon, class: Spree::Taxon do
    name 'Ruby on Rails'
    taxonomy { FactoryGirl.create(:taxonomy) }
    parent_id nil
  end
  
  # added for soletron
  factory :store_taxon, :parent => :taxon do
    name 'Nooka'
    taxonomy { FactoryGirl.create(:store_taxonomy) }
  end
  
  factory :store_taxon_with_store, :parent => :store_taxon do
    store { FactoryGirl.create(:store_without_taxon) }
    
    after(:create) do |taxon|
      if taxon.store.taxon.nil?
        taxon.store.taxon = taxon
        taxon.store.save
      end
    end
  end
  
  # added for soletron
  sequence(:category_taxon_name) {|n| "Category #{rand(1000)} #{n}"}
  factory :category_taxon, :parent => :taxon do
    name { FactoryGirl.generate :category_taxon_name } 
    taxonomy { Spree::Taxonomy.find_by_name('Categories') }
  end
  
  sequence(:commission_rate_sequence) { |n| rand(100) }
  
  factory :category_taxon_with_commission, :parent => :category_taxon do
    commission_rate { FactoryGirl.generate :commission_rate_sequence } 
  end
  
  factory :category_taxon_with_parent_with_commission, :parent => :category_taxon do
    parent { FactoryGirl.create(:category_taxon_with_commission) }
  end
end
