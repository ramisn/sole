FactoryGirl.define do
  factory :tax_category, class: Spree::TaxCategory do
    name { "TaxCategory - #{rand(999999)}" }
    description { Faker::Lorem.sentence }

    tax_rates { |r| [Spree::TaxRate.new(:amount => 0.05, :calculator => r.association(:calculator), :zone => Spree::Zone.global)] }
  end
end
