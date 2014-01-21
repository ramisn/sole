require 'spec_helper'

describe Spree::InventoryUnit do
  
  context "shoulda validations" do
    #it { should belong_to(:refund) }
    it { should belong_to(:line_item) }
  end
  
  ###
  # Need to override the state_machine of Inventory Unit and add a cancelled state
  # This will preserve the inventory unit
  # Need to have LineItem#cancel! be modified so that a cancellation happens
  # if all inventory units linked to the item are cancelled
  # Need to no longer have logic in after_cancel, or move it to an observer
  # If line item is cancelled then order should be cancelled as well, if all line items are cancelled
  # Need to override InventoryUnit.decrease, so that units are not destroy
  # After cancelling an inventory unit, need to send an email about it, put this in observer
  ###
  
  describe "#cancel!" do
    
    before :each do 
      @inventory_unit = FactoryGirl.create(:inventory_unit)
      InventoryUnitObserver.any_instance.stub(:after_cancel_to_canceled)
    end
    
    it "should transition from sold to canceled" do
      @inventory_unit.cancel!
      @inventory_unit.canceled?.should == true
    end
    
  end
  
end
