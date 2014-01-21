require 'spec_helper'

describe Spree::Promotion do
  
  describe "self#order_by_precedence" do
    
    it "should calculate the amount discounted" do
      [
        {
          sent: [
            FactoryGirl.build(:promotion, id: 2),
            FactoryGirl.build(:product_promotion, id: 3),
            FactoryGirl.build(:store_promotion, id: 1)
          ],
          returned: [3, 1, 2]
        },
        {
          sent: [
            FactoryGirl.build(:promotion, id: 2),
            FactoryGirl.build(:store_promotion, id: 1)
          ],
          returned: [1, 2]
        },
        {
          sent: [
            FactoryGirl.build(:promotion, id: 2),
            FactoryGirl.build(:product_promotion, id: 3),
          ],
          returned: [3, 2]
        },
      ].each do |scenario|
        sorted = Spree::Promotion.order_by_precedence(scenario[:sent])
        sorted.size.should == scenario[:returned].size
        scenario[:returned].size.times do |i|
          sorted[i].id.should == scenario[:returned][i]
        end
      end
    end
    
  end
  
end
