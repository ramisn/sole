require 'spec_helper'

describe InventoryUnitObserver do
  
  #describe "#decrement line item" do
  #  
  #end
  
  describe "#after_transition_state_to_canceled" do
    
    context "general" do
      
      before :each do
       @observer = InventoryUnitObserver.instance
      end
    
      it "should call cancel on shipment" do
        @inventory_unit = stub_and_return_association(FactoryGirl.create(:solo_inventory_unit), :shipment, :cancel)
        @observer.after_transition_state_to_canceled(@inventory_unit)
      end
      
      it "should call soft_cancel on line_item" do
        @inventory_unit = stub_and_return_association(FactoryGirl.create(:solo_inventory_unit), :line_item, :soft_cancel)
        @observer.after_transition_state_to_canceled(@inventory_unit)
      end
      
      it "should modify the quantity on the line item and in stock" do
        @inventory_unit = FactoryGirl.create(:multi_inventory_unit)
        old_amount = @inventory_unit.line_item.quantity
        new_amount = @inventory_unit.line_item.quantity - 1
        old_stock = @inventory_unit.line_item.variant.count_on_hand
        new_in_stock = @inventory_unit.line_item.variant.count_on_hand + 1
        @observer.after_transition_state_to_canceled(@inventory_unit)
        @inventory_unit.line_item.quantity.should == new_amount
        @inventory_unit.line_item.variant.count_on_hand.should == new_in_stock
      end
      
      it "should have the order flagged as credit owed" do
        @inventory_unit = FactoryGirl.create(:solo_inventory_unit)
        @observer.after_transition_state_to_canceled(@inventory_unit)
        @inventory_unit.order.payment_state.should == 'credit_owed'
      end
      
    end
    
    context "one unit integration" do
      
      before :each do
        @observer = InventoryUnitObserver.instance
        @inventory_unit = FactoryGirl.create(:solo_inventory_unit)
        order = @inventory_unit.order
        order.inventory_units.each do |iu|
          if iu != @inventory_unit
            iu.destroy
            order.inventory_units.delete(iu)
          end
        end
        order.save
        @inventory_unit.update_attribute_without_callbacks :state, 'canceled'
        @observer.after_transition_state_to_canceled(@inventory_unit)
      end
      
      it "should set the foodchain to canceled" do
        @inventory_unit.line_item.canceled?.should == true
        @inventory_unit.line_item.orders_store.canceled?.should == true
        @inventory_unit.line_item.order.canceled?.should == true
        @inventory_unit.line_item.orders_store.canceled?.should == true
      end
      
    end
    
  end
  
  #describe "#after_force_cancel_to_canceled" do
  #  
  #  it "should cancel the line item if all inventory units are canceled"
  #  it "should cancel the orders_store if all items in the orders_store are canceled"
  #  it "should cancel order if all items in the order are canceled"
  #  
  #end
  
end
