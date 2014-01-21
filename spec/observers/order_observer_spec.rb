require 'spec_helper'

describe OrderObserver do
  
  describe "#next_to_complete" do
    
    before :each do
      @line_item = FactoryGirl.create(:line_item)
      @store = @line_item.store
      @order = @line_item.order
      @order.stub!(:ensure_all_orders_stores)
      @order.stub!(:calculate_orders_stores)
      @order.stub!(:lock_line_item_commission_percentages)
      @order.stub!(:open_orders_stores)
      @observer = OrderObserver.instance
    end
    
    it "should set stores on the observed object" do
      @order.orders_stores.size.should == 1
      @order.should_receive(:ensure_all_orders_stores)
      @observer.after_next_to_complete(@order)
    end
    
    it "should set add the specific store information to each store" do
      @order.orders_stores.size.should == 1
      @order.should_receive(:calculate_orders_stores)
      @observer.after_next_to_complete(@order)
    end
    
    it "should lock the line item commission percentages" do
      @order.orders_stores.size.should == 1
      @order.should_receive(:lock_line_item_commission_percentages)
      @observer.after_next_to_complete(@order)
    end
    
    it "should tell order to open it's orders_stores" do
      @order.should_receive(:open_orders_stores)
      @observer.after_next_to_complete(@order)
    end
    
  end
  
end
