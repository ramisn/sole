require 'spec_helper'

describe OrdersStoreObserver do
  
  describe "#after_transition_state_to_complete" do
    
    before :each do
      @orders_store = FactoryGirl.create(:orders_store, :shipment_shipped)
      @observer = OrdersStoreObserver.instance
    end
    
    it "should set update the attribute completed at" do
      @observer.after_transition_state_to_complete(@orders_store)
      @orders_store.completed_at.should be_a_kind_of(Time)
    end
    
  end
  
  describe "#after_transition_state_to_closed_late" do
    
    before :each do
      @orders_store = FactoryGirl.create(:orders_store, :shipment_shipped)
      @observer = OrdersStoreObserver.instance
    end
    
    it "should set update the attribute completed at" do
      @observer.after_transition_state_to_closed_late(@orders_store)
      @orders_store.completed_at.should be_a_kind_of(Time)
    end
    
  end
  
  describe "#before_cancel_remaining" do
    
    before :each do
      @orders_store = FactoryGirl.create(:open_orders_store)
      @observer = OrdersStoreObserver.instance
      @observer.before_cancel_remaining(@orders_store)
    end
    
    it "should destroy all non-shipped shipments" do
      @orders_store.shipments.not_shipped.size == 0
    end
    
    it "should cancel all remaining inventory units" do
      @orders_store.inventory_units.not_shipped.each do |inventory_unit|
        inventory_unit.canceled?.should == true
      end
    end
    
    it "should cancel all line items that are have only canceled inventory units" do
      @orders_store.line_items.not_shipped.each do |line_item|
        line_item.canceled?.should == true
      end
    end

    # Is this test right? Looks depreciated
    pending "should set all line items that had some shipped items and no items shipped late to complete" do
      @orders_store.line_items.not_canceled.each do |line_item|
        if line_item.inventory_units.shipped.count == 0
          line_item.complete?.should == true
        end
      end
    end
    
    it "should set all line items that had some shipped items and at least one item that was shipped late to closed_late" do
      @orders_store.line_items.not_canceled.each do |line_item|
        if line_item.inventory_units.shipped.count == 0
          line_item.closed_late?.should == true
        end
      end
    end
    
    it "should set the quantity of each line item as the quantity of shipped inventory units" do
      @orders_store.line_items.each do |line_item|
        line_item.quantity.should == line_item.inventory_units.shipped.count
      end
    end
    
  end
  
  describe "#after_cancel_remaining" do
    
    before :each do
      @orders_store = FactoryGirl.create(:open_orders_store)
      #@orders_store.order.stub!(:update!)
      #@orders_store.order.stub!(:calculate_orders_stores)
      #@orders_store.order.stub!(:total).and_return(0)
      @observer = OrdersStoreObserver.instance
      @observer.before_cancel_remaining(@orders_store)
    end
    
    it "should update the order" do
      @orders_store.order.should_receive(:update!)
      @observer.after_cancel_remaining(@orders_store)
    end
    
    it "should calculate the orders_stores" do
      @orders_store.order.should_receive(:calculate_orders_stores)
      @observer.after_cancel_remaining(@orders_store)
    end
    
    it "should have the order flagged as credit owed" do
      @observer.after_cancel_remaining(@orders_store)
      @orders_store.order.payment_state.should == 'credit_owed'
    end
    
  end
  
  describe "#before_force_cancel" do
    
    before :each do
      @orders_store = FactoryGirl.create(:open_orders_store)
      @observer = OrdersStoreObserver.instance
      @observer.before_force_cancel(@orders_store)
    end
    
    it "should cancel all line items" do
      @orders_store.line_items.not_canceled.count.should == 0
    end
    
    it "should cancel all inventory units" do
      @orders_store.inventory_units.not_canceled.count.should == 0
    end
    
  end
  
  describe "#after_force_cancel" do
    
    before :each do
      @orders_store = FactoryGirl.create(:open_orders_store)
      @orders_store.stub!(:update!)
      @orders_store.stub!(:calculate_orders_stores)
      @observer = OrdersStoreObserver.instance
    end
    
    it "should update the order" do
      @orders_store.order.should_receive(:update!)
      @observer.after_force_cancel(@orders_store)
    end
    
    it "should re-calculate the order's stores" do
      @orders_store.order.should_receive(:calculate_orders_stores)
      @observer.after_force_cancel(@orders_store)
    end
    
  end
  
  describe "#after_transition_state_to_canceled" do
    
    before :each do
      @orders_store = FactoryGirl.create(:open_orders_store)
      @orders_store.order.stub!(:cancel)
      @observer = OrdersStoreObserver.instance
    end
    
    it "should call cancel on the order" do
      @orders_store.order.should_receive(:cancel)
      @observer.after_transition_state_to_canceled(@orders_store)
    end
    
  end
  
end