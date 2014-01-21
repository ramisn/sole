require 'spec_helper'

describe Spree::LineItem do
  
  before :all do
    @original_config = Spree::Config[:allow_backorders]
    Spree::Config.set(:allow_backorders => true)
  end
  
  after :all do
    Spree::Config.set(:allow_backorders => @original_config)
  end
  
  context "shoulda validations" do
    it { should have_many(:inventory_units) }
  end
  
  describe "#all_inventory_units_canceled?" do
    
    it "should return true if all inventory units were canceled" do
      @line_item = FactoryGirl.build(:canceled_line_item, variant: nil)
      @line_item.all_inventory_units_canceled?.should == true
    end
    
    it "should return false if one inventory unit was not canceled" do
      @line_item = FactoryGirl.build(:open_line_item, variant: nil)
      @line_item.all_inventory_units_canceled?.should == false
    end
    
  end
  
  describe "#all_units_shipped_on_time?" do
    
    it "should return true if all non-canceled inventory units were shipped on time" do
      @line_item = FactoryGirl.create(:shipped_line_item)
      @line_item.all_units_shipped_on_time?.should == true
    end
    
    it "should return false if one non-canceled inventory unit was not shipped or not shipped on time" do
      @line_item = FactoryGirl.create(:closed_late_line_item)
      @line_item.all_units_shipped_on_time?.should == false
    end
    
  end
  
  describe "#all_units_shipped?" do
    
    it "should return true if all non-canceled inventory units were shipped" do
      @line_item = FactoryGirl.create(:shipped_line_item)
      @line_item.all_units_shipped?.should == true
    end
    
    it "should return false if one non-canceled inventory unit was not shipped" do
      @line_item = FactoryGirl.create(:open_line_item)
      @line_item.all_units_shipped?.should == false
    end
    
  end
  
  describe "#copy_price" do
    
    it "should copy the uniform price and whether the item is on sale if it's pending and has a variant" do
      original_price = 1000.00
      @line_item = FactoryGirl.build(:line_item)
      @variant = @line_item.variant
      @line_item.stub!(:variant).and_return(@variant)
      
      [
        {:price => 10.0, :on_sale => true, :state => 'pending'},
        {:price => 20.0, :on_sale => false, :state => 'pending'},
        {:price => 5.0, :on_sale => true, :state => 'open'},
        {:price => 30.0, :on_sale => false, :state => 'open'}
      ].each do |variant_set|
        @line_item.price = original_price
        @line_item.stub!(:state).and_return(variant_set[:state])
        @variant.stub!(:uniform_price).and_return(variant_set[:price])
        @variant.stub!(:sale?).and_return(variant_set[:on_sale])
        
        @line_item.copy_price
        
        if @line_item.state != 'pending'
          @line_item.price.should == 1000.00
          @line_item.on_sale.should == false
        else
          @line_item.price.should == @variant.uniform_price
          @line_item.on_sale.should == variant_set[:on_sale]
        end
      end
    end
    
  end
  
  describe "#free_shipping_credits" do
    
    it "should return one free shipping credit" do
      line_item = FactoryGirl.create(:open_line_item, quantity: 4)
      line_item.line_item_promotion_credits << FactoryGirl.create(:line_item_promotion_credit, line_item: line_item)
      line_item.line_item_promotion_credits << FactoryGirl.create(:free_shipping_line_item_promotion_credit, line_item: line_item)
      line_item.free_shipping_credits.size.should == 1
    end
    
  end
  
  describe "#non_free_shipping_credits" do
    
    it "should return one non-free shipping credit" do
      line_item = FactoryGirl.create(:open_line_item, quantity: 4)
      line_item.line_item_promotion_credits << FactoryGirl.create(:line_item_promotion_credit, line_item: line_item)
      line_item.line_item_promotion_credits << FactoryGirl.create(:free_shipping_line_item_promotion_credit, line_item: line_item)
      line_item.non_free_shipping_credits.size.should == 1
    end
  end
  
  describe "#quantity_available" do
    
    before :each do
      @line_item = FactoryGirl.create(:open_line_item, quantity: 4)
      @line_item.line_item_promotion_credits << FactoryGirl.create(:line_item_promotion_credit, line_item: @line_item)
      @line_item.line_item_promotion_credits << FactoryGirl.create(:free_shipping_line_item_promotion_credit, line_item: @line_item)
    end
    
    it "should return the line item's quantity with no argument sent" do
      @line_item.quantity_available.should == 4
    end
    
    it "should return line item promotion credits for free shipping when shipping is sent" do
      @line_item.quantity_available(:free_shipping).should == 3
    end
    
    it "should return line item promotion credits for that are not free shipping when promotion is sent" do
      @line_item.quantity_available(:promotion).should == 2
    end
    
  end
  
  context "state transitions" do
    
    describe "#force_cancel" do
      
      it "should transition from open to canceled" do
        @line_item = FactoryGirl.create(:open_line_item)
        @line_item.force_cancel
        @line_item.canceled?.should == true
      end
      
      it "should transition from shipped to canceled" do
        @line_item = FactoryGirl.create(:shipped_line_item)
        @line_item.force_cancel
        @line_item.canceled?.should == true
      end
      
    end
    
    describe "#soft_cancel" do
      
      it "should transition to canceled if all units were canceled" do
        @line_item = FactoryGirl.create(:canceled_line_item)
        @line_item.update_attribute_without_callbacks :state, 'open'
        @line_item.soft_cancel
        @line_item.canceled?.should == true
      end
      
      it "should transition to closed if all non-canceled units were shipped on time" do
        @line_item = FactoryGirl.create(:shipped_line_item)
        @line_item.update_attribute_without_callbacks :state, 'open'
        @line_item.soft_cancel
        @line_item.closed?.should == true
      end
      
      it "should transition to closed late if all non-canceled units were shipped" do
        @line_item = FactoryGirl.create(:closed_late_line_item)
        @line_item.update_attribute_without_callbacks :state, 'open'
        @line_item.soft_cancel
        @line_item.closed_late?.should == true
      end
      
    end
    
  end
  
  describe "#orders_store" do
    
    it "should return an orders_store with order and store that are the same" do
      @line_item = FactoryGirl.create(:line_item)
      @line_item.order.ensure_all_orders_stores
      @orders_store = @line_item.orders_store
      @orders_store.should_not be_nil
      @orders_store.store.should == @line_item.store
      @orders_store.order.should == @line_item.order
    end
    
  end
  
  describe "#calculate!" do
    
    before :each do
      @line_item = FactoryGirl.create(:line_item)
      @line_item.stub!(:calculate_total_amount!)
      @line_item.stub!(:calculate_commission_percentage!)
      @line_item.stub!(:calculate_store_amount!)
      @line_item.stub!(:save)
    end
    
    it "should calculate the total amount" do
      @line_item.should_receive(:calculate_total_amount!)
      @line_item.calculate!
    end
    
    it "should calculate the commission percentage" do
      @line_item.should_receive(:calculate_commission_percentage!)
      @line_item.calculate!
    end
    
    it "should calculate the store amount" do
      @line_item.should_receive(:calculate_store_amount!)
      @line_item.calculate!
    end
    
    it "should save the line item" do
      @line_item.should_receive(:save)
      @line_item.calculate!
    end
    
  end
  
  describe "#calculate_total_amount!" do
    
    before :each do
      @line_item = FactoryGirl.create(:line_item)
    end
    
    it "should access the price" do
      @line_item.stub!(:price).and_return(5)
      @line_item.stub!(:quantity).and_return(5)
      @line_item.should_receive(:price)
      @line_item.send :calculate_total_amount!
    end
    
    it "should access quantity" do
      @line_item.stub!(:price).and_return(5)
      @line_item.stub!(:quantity).and_return(5)
      @line_item.should_receive(:quantity)
      @line_item.send :calculate_total_amount!
    end
    
    it "should set the total amount to price times quantity" do
      @line_item.send :calculate_total_amount!
      @line_item.total_amount.should == @line_item.price * @line_item.quantity
    end
    
  end
  
  describe "#calculate_commission_percentage!" do
    
    context "with store tier" do
      
      before :each do
        @line_item = FactoryGirl.create(:line_item, :store => FactoryGirl.create(:store_with_tier))
      end
      
      it "should find a store tier" do
        @line_item.store.should_receive(:store_tier)
        @line_item.send :calculate_commission_percentage!
      end
      
      it "should find the variant commission" do
        @line_item.variant.stub!(:commission_percentage).and_return(30.0)
        @line_item.variant.should_receive(:commission_percentage)
        @line_item.send :calculate_commission_percentage!
      end
      
      it "should set the commission" do
        @line_item.send(:calculate_commission_percentage!)
        @line_item.commission_percentage.should_not be_nil
      end
      
      it "should set the commission equal to the related taxon times the discount" do
        expected_commission_percentage = @line_item.variant.commission_percentage * (@line_item.store.store_tier.discount / 100)
        @line_item.send(:calculate_commission_percentage!)
        @line_item.commission_percentage.should == expected_commission_percentage
      end
      
    end
    
    context "without store tier" do
      
      before :each do
        @line_item = FactoryGirl.create(:line_item, :store => FactoryGirl.create(:store))
      end
      
      it "should find a store tier" do
        @line_item.store.should_receive(:store_tier)
        @line_item.send(:calculate_commission_percentage!)
      end
     
      it "should find the variant commission" do
        @line_item.variant.stub!(:commission_percentage).and_return(30.0)
        @line_item.variant.should_receive(:commission_percentage)
        @line_item.send(:calculate_commission_percentage!)
      end
      
      it "should set the commission" do
        @line_item.send(:calculate_commission_percentage!)
        @line_item.commission_percentage.should_not be_nil
      end
      
      it "should set the commission equal to the related taxon commission" do
        expected_commission_percentage = @line_item.variant.commission_percentage
        @line_item.send(:calculate_commission_percentage!)
        @line_item.commission_percentage.should == expected_commission_percentage
      end
      
    end
    
    context "changing state of line item" do
      
      before :each do
        @line_item = FactoryGirl.create(:line_item, :store => FactoryGirl.create(:store_with_tier))
        @line_item.send(:calculate_commission_percentage!)
      end
      
      it "should change the commission percentage if the line item's commission percentage is not locked" do
        @line_item.should_receive(:commission_percentage=)
        @line_item.update_attribute_without_callbacks :commission_percentage_lock, false
        @line_item.send(:calculate_commission_percentage!)
      end
      
      it "should not change the commission percentage if the line item's commission percentage is locked" do
        @line_item.should_not_receive(:commission_percentage=)
        @line_item.update_attribute_without_callbacks :commission_percentage_lock, true
        @line_item.send(:calculate_commission_percentage!)
      end
      
    end
    
  end
  
  describe "#calculate_store_amount!" do
    
    before :each do
      @line_item = FactoryGirl.create(:line_item, :store => FactoryGirl.create(:store_with_tier))
      @line_item.send(:calculate_total_amount!)
      @total_amount = @line_item.total_amount
      @line_item.send(:calculate_commission_percentage!)
      @store_rate = 100 - @line_item.commission_percentage
    end
    
    it "should get the total amount" do
      @line_item.stub!(:total_amount).and_return(@total_amount)
      @line_item.should_receive(:total_amount)
      @line_item.send(:calculate_store_amount!)
    end
    
    it "should get the commission percentage" do
      @line_item.stub!(:commission_percentage).and_return(30.0)
      @line_item.should_receive(:commission_percentage)
      @line_item.send(:calculate_store_amount!)
    end
    
    it "should set the store amount as the total amount without the commission" do
      @line_item.send(:calculate_store_amount!)
      @line_item.store_amount.should == @total_amount * (@store_rate / 100)
    end
    
  end
  
end
