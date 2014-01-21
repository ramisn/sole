require 'spec_helper'

describe Spree::Calculator::BuyXGetYAtZPercentOff do
  
  describe "#compute" do
    
    it "should calculate the amount discounted" do
      @order = FactoryGirl.build(:order)
      @calculator = FactoryGirl.build(:flat_percent_calculator)
      @calculator.stub!(:calculable).and_return(FactoryGirl.build(:promotion))
      [
        {
          line_items: [
            FactoryGirl.build(:open_line_item, id: 1, quantity: 2, price: 20.0),
            FactoryGirl.build(:open_line_item, id: 2, quantity: 1, price: 10.0)
          ], 
          lipc_count: 2,
          lipc_quantity: {1 => 2, 2 => 1},
          lipc_amount: {1 => -8.0, 2 => -2.0},
          flat_percent_off: 20.0,
          value: 10.0 # the lowest cost line item should be 50% off
        },
        {
          line_items: [
            FactoryGirl.build(:open_line_item, id: 1, quantity: 1, price: 20.0),
            FactoryGirl.build(:open_line_item, id: 2, quantity: 1, price: 10.0)
          ], 
          lipc_count: 2,
          lipc_quantity: {1 => 1, 2 => 1},
          lipc_amount: {1 => -10.0, 2 => -5.0},
          flat_percent_off: 50.0,
          value: 15.0 # not enough items
        },
        {
          line_items: [
            FactoryGirl.build(:open_line_item, id: 1, quantity: 2, price: 20.0),
            FactoryGirl.build(:open_line_item, id: 2, quantity: 2, price: 10.0)
          ], 
          lipc_count: 2,
          lipc_quantity: {1 => 2, 2 => 2},
          lipc_amount: {1 => -4.0, 2 => -2.0},
          flat_percent_off: 10.0,
          value: 6.0 # not enough items
        },
        {
          line_items: [
            FactoryGirl.build(:open_line_item, id: 1, quantity: 0, price: 20.0),
            FactoryGirl.build(:open_line_item, id: 2, quantity: 0, price: 10.0)
          ], 
          lipc_count: 0,
          lipc_quantity: {},
          lipc_amount: {},
          flat_percent_off: 50.0,
          value: 0 # require x > 0
        }
      ].each do |scenario|
        @calculator.stub!(:line_items_for_compute).with(@order).and_return(scenario[:line_items])
        @calculator.stub!(:preferred_flat_percent_off).and_return(scenario[:flat_percent_off])
        amount, line_items = @calculator.compute(@order)
        amount.should == scenario[:value]
        line_items.should_not be_nil
        line_items.count.should == scenario[:lipc_quantity].keys.count
        line_items.each do |lipc|
          lipc.is_a?(LineItemPromotionCredit).should be_true
          scenario[:lipc_quantity][lipc.line_item.id].should == lipc.quantity
          scenario[:lipc_amount][lipc.line_item.id].should == lipc.amount
        end
      end
    end
    
  end
  
end
