require 'spec_helper'
# A rule to limit a promotion to a specific user.
describe Spree::Promotion::Rules::StoreTotal do
  
  describe "#eligible?" do
    
    before :each do
      @store_total_rule = FactoryGirl.create(:store_total_promotion_rule)
      @store = @store_total_rule.promotion.store
      @order = FactoryGirl.create(:order)
      
      @variant = FactoryGirl.create(:variant)
      @variant.product.taxons << FactoryGirl.create(:store_taxon_with_store, store: @store)
      @variant.product.save
      
      @line_item = FactoryGirl.create(:open_line_item, variant: @variant, quantity: 1)
      @line_item.calculate!
      @line_item.save
    end
    
    it "should not be eligible when the store does not have an orders store" do
      @store_total_rule.eligible?(@order).should_not be_true
    end
    
    it "should not be eligible when the store's orders store is less than the rule amount" do
      @line_item.order = @order
      @line_item.store = @store
      @line_item.save(validate: false)
      
      @order.line_items.reload
      @order.ensure_all_orders_stores
      @order.calculate_orders_stores
      @order.save
      
      @store_total_rule.eligible?(@order).should_not be_true
    end
    
    it "should be eligible when the store total is over the amount for the rule" do
      @line_item.order = @order
      @line_item.store = @store
      @line_item.update_attributes quantity: 6, total_amount: 6 * @line_item.price
      @line_item.calculate!
      @line_item.save(validate: false)
      
      @order.line_items.reload
      @order.ensure_all_orders_stores
      @order.calculate_orders_stores
      @order.save
      
      @store_total_rule.eligible?(@order).should be_true
    end
    
  end
  
end
