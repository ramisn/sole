require 'spec_helper'

describe Spree::Calculator do
  
  describe "#line_items_for_compute" do
    
    before :all do
      @order = FactoryGirl.create(:order)
      FactoryGirl.create(:open_line_item, order: @order)
      FactoryGirl.create(:on_sale_line_item, order: @order)
      @order.line_items.reload
      @order.ensure_all_orders_stores
      @order.calculate_orders_stores
      @calculator = FactoryGirl.build(:calculator)
    end
    
    describe "not a promotion" do
      
      before :each do 
        @calculable = FactoryGirl.create(:adjustment)
        @calculator.stub!(:calculable).and_return(@calculable)
      end
      
      it "should return all order line items" do
        line_items = @calculator.line_items_for_compute(@order)
        line_items.count.should == 2
        line_items.should == @order.line_items
      end
      
    end
    
    describe "global promotion" do
      
      before :each do 
        @calculable = FactoryGirl.create(:promotion)
        @calculator.stub!(:calculable).and_return(@calculable)
      end
      
      it "should not return line items on sale" do
        line_items = @calculator.line_items_for_compute(@order)
        line_items.count.should == 1
        line_items.each do |line_item|
          line_item.on_sale?.should == false
        end
      end
      
    end
    
    describe "global free shipping promotion" do
      
      before :each do 
        @calculable = FactoryGirl.create(:promotion)
        @calculator.stub!(:calculable).and_return(@calculable)
      end
      
      it "should return all line items" do
        @order.line_items.count == @calculator.line_items_for_compute(@order)
      end
    end
    
    describe "store promotion" do
      
      before :each do 
        @calculable = FactoryGirl.create(:store_promotion)
        @store = @calculable.store
        @calculator.stub!(:calculable).and_return(@calculable)
        line_item = @order.line_items.not_on_sale.first
        line_item.store = @store
        line_item.save
        @order.line_items.reload
      end
      
      it "should return all store line items" do
        line_items = @calculator.line_items_for_compute(@order)
        line_items.count.should == 1
        line_items.each do |line_item|
          line_item.store.should == @store
        end
      end
      
    end
    
    describe "product promotion" do
      
      before :each do 
        @calculable = FactoryGirl.create(:product_promotion)
        @calculator.stub!(:calculable).and_return(@calculable)
        line_item = @order.line_items.not_on_sale.first
        line_item.variant.product = @calculable.product
        line_item.variant.save
      end
      
      it "should return all line items matching product" do
        line_items = @calculator.line_items_for_compute(@order)
        line_items.count.should == 1
        line_items.each do |line_item|
          line_item.variant.product.master.product.should == @calculable.product
        end
      end
      
    end
    
  end
  
  describe "#compute_line_items" do
    
    it "by default it should return values determined by save_value for all of the items"

    it "should return an appropriate array of linked_object class instances when linked_object is provided"
    
  end
  
end
