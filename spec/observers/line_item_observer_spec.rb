require 'spec_helper'

describe LineItemObserver do
  
  before :all do
    @original_config = Spree::Config[:allow_backorders]
    Spree::Config.set(:allow_backorders => true)
  end
  
  after :all do
    Spree::Config.set(:allow_backorders => @original_config)
  end
  
  
  describe "#before_force_cancel" do
    
    before :each do |line_item|
      @line_item = FactoryGirl.create(:open_line_item)
      @observer = LineItemObserver.instance
      @observer.before_force_cancel(@line_item)
    end
    
    it "should cancel all not shipped inventory units" do
      @line_item.inventory_units.not_shipped.not_canceled.count.should == 0
    end
    
    it "should set quantity to 0" do
      @line_item.quantity.should == 0
    end
    
  end
  
  describe "#after_transition_state_to_canceled" do
    
    # check to see if all inventory units are canceled, if so, then cancel it
    it "should call order_store#cancel is all inventory units are cancelled" do
      @line_item = stub_and_return_association(FactoryGirl.create(:canceled_line_item), :orders_store, :cancel)
      @observer = LineItemObserver.instance
      @observer.after_transition_state_to_canceled(@line_item)
    end
    
  end
  
  #describe "#after_force_cancel_to_canceled" do
  #  
  #  it "should call to cancel it's orders_store" do
  #    @line_item = stub_and_return_association(FactoryGirl.create(:canceled_line_item), :orders_store, :cancel)
  #    @observer = LineItemObserver.instance
  #    @observer.after_force_cancel_to_canceled(@line_item)
  #  end
  #  
  #end
  
  describe "#after_create" do
    
    before :each do
      @store = FactoryGirl.create(:store)
      @order = FactoryGirl.create(:order)
      @order.stub!(:ensure_orders_store)
      @observer = LineItemObserver.instance
    end
    
    it "should call ensure_orders_store after creating a line item" do
      @line_item = FactoryGirl.build(:line_item, :order => @order, :store => @store)
      @order.should_receive(:ensure_orders_store)
      @observer.after_create(@line_item)
    end
    
  end
  
  describe "#after_destroy" do
    
    before :each do
      @line_item = FactoryGirl.create(:line_item)
      @store = @line_item.store
      @order = @line_item.order
      @observer = LineItemObserver.instance
    end
    
    it "should call check_to_remove_orders_store after destroying a line item" do
      @order.should_receive(:check_to_remove_orders_store)
      @observer.after_destroy(@line_item)
    end
    
  end
end
