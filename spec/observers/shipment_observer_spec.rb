require 'spec_helper'

describe ShipmentObserver do
  
  describe "#after_force_cancel_to_canceled" do
    
    before :each do
      @order = Factory.custom_order(:shipped => true)
      @shipment = @order.shipments.first
      @observer = ShipmentObserver.instance
    end
    
    it "should set all inventory units to canceled" do
      @observer.after_force_cancel_to_canceled(@shipment)
      @shipment.inventory_units.each do |inventory_unit|
        inventory_unit.canceled?.should == true
      end
    end
    
    it "should decrement the line items" do
      @shipment.inventory_units.each do |inventory_unit|
        inventory_unit.line_item.should_receive(:decrement_quantity)
        inventory_unit.line_item.should_receive(:save)
      end
      @observer.after_force_cancel_to_canceled(@shipment)
    end
  end

end
