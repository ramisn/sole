require 'spec_helper'

describe Merchant::OrdersController do
  
  describe "#index" do
    
    before :each do
      set_merchant(controller)
      get :index, :store_id => @store.id
    end
    
    it "should assign @orders and load index" do
      assigns(:orders)
    end
    
    it "should load successfully" do
      response.should render_template("index")
    end
    
  end
  
  describe "#edit" do
    
    before :each do
      set_merchant(controller)
      @orders_store = FactoryGirl.create(:open_orders_store, :store => @store)
      get :edit, :store_id => @store.id, :id => @orders_store.order.number
    end
    
    it "should assign @order and @orders_stores" do
      assigns(:order).should == @orders_store.order
      assigns(:orders_store).should == @orders_store
    end
    
    it "should load successfully" do
      response.should render_template("edit")
    end
    
  end
  
  describe "#ship" do
    
    describe "success" do
      
      before :each do
        set_merchant(controller)
        @orders_store = FactoryGirl.create(:open_orders_store, :store => @store)
        @shipment = @orders_store.shipments.first
        @shipping_method = FactoryGirl.create(:shipping_method)
        inventory_units = {}
        first_iu = @shipment.inventory_units.first
        second_iu = @shipment.inventory_units.second
        inventory_units[first_iu.id] = first_iu.id
        inventory_units[second_iu.id] = second_iu.id
        put :ship, :store_id => @store.id, 
            :id => @orders_store.order.number, 
            :shipment => {:id => @shipment.id, :tracking => "hi", :vendor_shipping_method => @shipping_method.name},
            :inventory_units => inventory_units
      end
      
      it "should assign @shipment" do
        assigns(:shipment).should == @shipment
      end
      
      it "should set shipment as shipped" do
        assigns(:shipment).shipped?.should == true
      end
      
      it "should have assigned shipped_at on shipment" do
        assigns(:shipment).shipped_at.should be_a_kind_of(Time)
      end
    
      it "should redirect back to the order's edit page on success" do
        response.should redirect_to(edit_merchant_store_order_path(@orders_store.store, @orders_store.order))
      end
      
    end
    
    describe "failure" do
      
      before :each do
        set_merchant(controller)
        @orders_store = FactoryGirl.create(:open_orders_store, :store => @store)
        @shipment = @orders_store.shipments.first
        @shipping_method = FactoryGirl.create(:shipping_method)
        ShipmentMailer.stub!(:shipped_email)
        put :ship, :store_id => @store.id, :id => @orders_store.order.number, :shipment => {:id => @shipment.id}
      end
      
      it "should render the edit page on failure" do
        response.should render_template("edit")
      end
      
    end
    
  end
  
  describe "#confirm_cancel_remaining" do
    
    before :each do
      set_merchant(controller)
      @orders_store = FactoryGirl.create(:open_orders_store)
      get :confirm_cancel_remaining, :store_id => @orders_store.store.id, :id => @orders_store.order.number
    end
    
    it "should assign @orders_store and @order and @store" do
      assigns(:orders_store).should == @orders_store
      assigns(:order).should == @orders_store.order
      assigns(:store).should == @orders_store.store
    end
    
    it "should render the confirm_cancel template" do
      response.should render_template("confirm_cancel_remaining")
    end
    
  end
  
  describe "#cancel_remaining" do
    
    describe "success" do
      
      before :each do
        set_merchant(controller)
        @orders_store = FactoryGirl.create(:open_orders_store, :store => @store)
        put :cancel_remaining, :store_id => @orders_store.store.id, :id => @orders_store.order.number
      end
      
      it "should assign @orders_store" do
        assigns(:orders_store).should == @orders_store
      end
      
      it "should set all of the non-shipped inventory units to canceled" do
        assigns(:orders_store).inventory_units.each do |inventory_unit|
          (inventory_unit.shipped? || inventory_unit.canceled?).should == true
        end
      end
      
      it "should redirect back to the order edit page on success" do
        response.should redirect_to(edit_merchant_store_order_path(@orders_store.store, @orders_store.order))
      end
      
    end
    
    describe "send email" do
      
      it "should send an email that items have been canceled" do
        set_merchant(controller)
        @orders_store = FactoryGirl.create(:open_orders_store, :store => @store)
        return_mailer = Spree::OrderMailer.cancel_email(@orders_store.order)
        Spree::OrderMailer.should_receive(:cancel_email).and_return(return_mailer)
        put :cancel_remaining, :store_id => @orders_store.store.id, :id => @orders_store.order.number
      end
      
    end
    
  end
  
  describe "#confirm_force_cancel" do
    
    context "with merchant" do
      
      it "should not render confirm_force_cancel" do
        set_merchant(controller)
        @orders_store = FactoryGirl.create(:open_orders_store, :store => @store)
        get :confirm_force_cancel, :store_id => @orders_store.store.id, :id => @orders_store.order.number
        response.should_not render_template("confirm_force_cancel")
      end
      
    end
    
    context "with admin" do
      
      before :each do
        set_admin(controller)
        @orders_store = FactoryGirl.create(:open_orders_store)
        get :confirm_force_cancel, :store_id => @orders_store.store.id, :id => @orders_store.order.number
      end
      
      it "should assign @orders_store and @order and @store" do
        assigns(:orders_store).should == @orders_store
        assigns(:order).should == @orders_store.order
        assigns(:store).should == @orders_store.store
      end
      
      it "should render the confirm_cancel template" do
        response.should render_template("confirm_force_cancel")
      end
      
    end
    
  end
  
  describe "#force_cancel" do
    
    context "with merchant" do
      
      it "should not cancel the orders_store" do
        set_merchant(controller)
        @orders_store = FactoryGirl.create(:open_orders_store, :store => @store)
        put :force_cancel, :store_id => @orders_store.store.id, :id => @orders_store.order.number
        controller.flash[:error].should == "You are not authorized to conduct that action"
        assigns(:orders_store).should be_nil
      end
      
    end
    
    describe "#success" do
      
      before :each do
        set_admin(controller)
        @orders_store = FactoryGirl.create(:open_orders_store)
        put :force_cancel, :store_id => @orders_store.store.id, :id => @orders_store.order.number
      end
      
      it "should assign @orders_store" do
        assigns(:orders_store).should == @orders_store
      end
      
      it "should set all of the non-shipped inventory units to canceled" do
        assigns(:orders_store).inventory_units.each do |inventory_unit|
          inventory_unit.canceled?.should == true
        end
      end
      
      it "should cancel the orders_store" do
        assigns(:orders_store).canceled?.should == true
      end
      
      it "should redirect back to the order edit page on success" do
        response.should redirect_to(edit_merchant_store_order_path(@orders_store.store, @orders_store.order))
      end
      
    end
    
    describe "send email" do
      
      it "should send an email that items have been canceled" do
        set_admin(controller)
        @orders_store = FactoryGirl.create(:open_orders_store)
        return_mailer = OrderMailer.cancel_email(@orders_store.order)
        OrderMailer.should_receive(:cancel_email).and_return(return_mailer)
        put :force_cancel, :store_id => @orders_store.store.id, :id => @orders_store.order.number
      end
      
    end
    
  end
  
  describe "#cancel" do
    
    describe "success" do
      
      before :each do
        set_merchant(controller)
        @orders_store = FactoryGirl.create(:open_orders_store, :store => @store)
        #OrdersStore.any_instance.stub!(:cancel_remaining!)
        put :cancel, :store_id => @orders_store.store.id, :id => @orders_store.order.number
      end
      
      it "should assign @orders_store" do
        assigns(:orders_store).should == @orders_store
      end
      
      it "should set all of the non-shipped inventory units to canceled" do
        assigns(:orders_store).inventory_units.each do |inventory_unit|
          (inventory_unit.shipped? || inventory_unit.canceled?).should == true
        end
      end
      
      it "should redirect back to the order edit page on success" do
        response.should redirect_to(edit_merchant_store_order_path(@orders_store.store, @orders_store.order))
      end
      
    end
    
    describe "send email" do
      
      it "should send an email about the canceled items" do
        set_merchant(controller)
        @orders_store = FactoryGirl.create(:open_orders_store, :store => @store)
        return_mailer = Spree::OrderMailer.cancel_email(@orders_store.order)
        Spree::OrderMailer.should_receive(:cancel_email).and_return(return_mailer)
        put :cancel, :store_id => @orders_store.store.id, :id => @orders_store.order.number
      end
      
    end
    
  end
  
  describe "#cancel_item" do
    
    describe "success" do
      
      before :each do
        set_merchant(controller)
        @orders_store = FactoryGirl.create(:open_orders_store, :store => @store)
        #InventoryUnit.any_instance.stub(:cancel!)
        @inventory_unit = @orders_store.shipments.first.inventory_units.first
        put :cancel_item, :store_id => @orders_store.store.id, :id => @orders_store.order.number, :inventory_unit_id => @inventory_unit.id
      end
      
      it "should assign the inventory unit" do
        assigns(:inventory_unit).should == @inventory_unit
      end
      
      it "should cancel the inventory unit" do
        assigns(:inventory_unit).canceled?.should == true
      end
      
      it "should redirect back to the order edit page" do
        response.should redirect_to(edit_merchant_store_order_path(@orders_store.store, @orders_store.order))
      end
      
    end
    
    describe "send email" do
      
      it "should send an email that items have been canceled" do
        set_merchant(controller)
        @orders_store = FactoryGirl.create(:open_orders_store, :store => @store)
        Spree::InventoryUnit.any_instance.stub(:cancel!)
        @inventory_unit = @orders_store.shipments.first.inventory_units.first
        return_mailer = Spree::OrderMailer.cancel_email(@inventory_unit.order)
        Spree::OrderMailer.should_receive(:cancel_email).and_return(return_mailer)
        put :cancel_item, :store_id => @orders_store.store.id, :id => @orders_store.order.number, :inventory_unit_id => @inventory_unit.id
      end
      
    end
      
  end
  
end
