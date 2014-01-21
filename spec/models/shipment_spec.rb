require 'spec_helper'

describe Spree::Shipment do
  
  context "state events" do
    
    describe "#cancel" do
      
      it "should cancel if all inventory units are already canceled" do
        
      end
      
    end
    
    describe "#force_cancel" do
      
      it "should change the pending shipment canceled" do
        @order = Factory.custom_order
        @shipment = @order.shipments.first
        @shipment.update_attribute_without_callbacks 'state', 'pending'
        @shipment.force_cancel!
        @shipment.canceled?.should == true
      end
      
      it "should change the ready shipment to canceled" do
        @order = Factory.custom_order
        @shipment = @order.shipments.first
        #@shipment.ready!
        @shipment.force_cancel!
        @shipment.canceled?.should == true
      end
      
    end
    
  end
  
  describe "#all_inventory_units_canceled?" do
    
    it "should return true if all inventory units have been canceled" do
      @shipment = FactoryGirl.create(:canceled_shipment)
      @shipment.all_inventory_units_canceled?.should == true
    end
    
    it "should return false if any inventory unit has not been canceled" do
      @shipment = FactoryGirl.create(:pending_shipment)
      @shipment.all_inventory_units_canceled?.should == false
    end
    
  end
  
  describe "#late?" do
    
    it "should return false if the shipment is not shipped and is less than two days old" do
      @shipment = FactoryGirl.create(:pending_shipment)
      @shipment.late?.should == false
    end
    
    it "should return false if the shipment is shipped and was shipped in less than two days" do
      @shipment = FactoryGirl.create(:shipped_shipment)
      @shipment.late?.should == false
    end
    
    it "should return true if the shipment is not shipped and is older than two days" do
      @shipment = FactoryGirl.create(:late_pending_shipment)
      @shipment.late?.should == true
    end
    
    it "should return true if the shipment is shipped and is older than two days" do
      @shipment = FactoryGirl.create(:late_shipped_shipment)
      @shipment.late?.should == true
    end
    
  end
  
end
