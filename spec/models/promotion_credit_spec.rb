require 'spec_helper'

describe Spree::Adjustment do
  
  
  
  describe "#calculate_coupon_credit" do
    
    it "should calculate the amount of all non-sale line items in the order" do
      @promotion_credit = FactoryGirl.build(:promotion_credit)
      
      [
        { :not_on_sale => [] },
        { :not_on_sale => [FactoryGirl.build(:line_item, :price => 20.00, :quantity => 2)]},
        { :not_on_sale => [FactoryGirl.build(:line_item, :price => 20.00), FactoryGirl.build(:line_item, :price => 15.00)]}
      ].each_with_index do |line_item_set, index|
        @promotion_credit.order.line_items.stub!(:not_on_sale).and_return(line_item_set[:not_on_sale])
        @promotion_credit.order.stub!(:item_total).and_return(@promotion_credit.order.line_items.not_on_sale.map(&:amount).sum)
        
        @promotion_credit.calculate_coupon_credit.should == 0 if line_item_set[:not_on_sale].empty?
        @promotion_credit.calculate_coupon_credit.should < 0 if !line_item_set[:not_on_sale].empty?
      end
    end
    
  end
  
end
