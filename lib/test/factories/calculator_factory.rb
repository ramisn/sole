FactoryGirl.define do
  factory :calculator, :class => Spree::Calculator::FlatRate do
    calculable { FactoryGirl.build(:promotion_create_adjustment) }
    after(:build) { |c| c.set_preference(:amount, 10.0) }
  end
  
  factory :free_shipping_calculator, class: Spree::Calculator::FreeShipping do
    calculable { FactoryGirl.build(:promotion_create_adjustment) }
  end
  
  factory :basic_shipping_calculator, :class => Spree::Calculator::FlexiRate do
    after(:create) do |c| 
      c.set_preference(:first_item, 4.99)
      c.set_preference(:additional_item, 1.00)
    end
  end

  factory :no_amount_calculator, :class => Spree::Calculator::FlatRate do
    after(:create) { |c| c.set_preference(:amount, 0) }
  end
  
  factory :buy_x_get_y_at_z_percent_off_calculator, class: Spree::Calculator::BuyXGetYAtZPercentOff do
    calculable { FactoryGirl.build(:promotion_create_adjustment) }
    after(:create) do |c|
      c.set_preference :buy_number_of_items_x, 2
      c.set_preference :get_number_of_items_y, 1
      c.set_preference :at_z_percent_off, 50.0
    end
  end
  
  factory :flat_percent_calculator, class: Spree::Calculator::FlatPercent do
    #calculable { puts "adding promotion create adjustment as calculable"; FactoryGirl.build(:promotion_create_adjustment) }
    after(:create) do |c|
      puts "flat percent calculator created"
      c.set_preference :flat_percent_off, 50.0
    end
  end
end
