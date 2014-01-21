require 'spec_helper'

describe Merchant::InventoryUnitsController do
  
  describe "#confirm_cancel" do
    
    before :each do
      set_merchant(controller)
      @inventory_unit = Factory.custom_inventory_unit(:solo_inventory_unit, :store => @store)
      get :confirm_cancel, :id => @inventory_unit.id, :store_id => @store.id
    end
    
    it "should set @inventory_unit and render the confirm_cancel template" do
      assigns(:inventory_unit).should == @inventory_unit
      response.should render_template("confirm_cancel")
    end
    
  end
  
  describe "#cancel" do
    
    describe "success" do
      
      before :each do
        set_merchant(controller)
        @inventory_unit = Factory.custom_inventory_unit(:solo_inventory_unit, :store => @store)
        put :cancel, :id => @inventory_unit.id, :store_id => @store
      end
      
      it "should set the inventory unit" do
        assigns(:inventory_unit).should == @inventory_unit
      end
      
      it "should have the inventory set to canceled" do
        assigns(:inventory_unit).canceled?.should == true
      end
      
      it "should set the success flash message" do
        flash[:success].should_not be_nil
      end
      
      it "should redirect to the merchant store order page" do
        response.should redirect_to(edit_merchant_store_order_path(@store, @inventory_unit.order))
      end
      
    end
    
    describe "integration chain on cancel" do
      
      before :each do
        set_merchant(controller)
        @inventory_unit = Factory.custom_inventory_unit(:solo_inventory_unit, :store => @store)
        put :cancel, :id => @inventory_unit.id, :store_id => @store
      end
      
      it "should set the chain to canceled when there is only one inventory unit" do
        response.should redirect_to(edit_merchant_store_order_path(@store, @inventory_unit.order))
        assigns(:inventory_unit).canceled?.should == true
        assigns(:inventory_unit).shipment.canceled?.should == true
        assigns(:inventory_unit).line_item.canceled?.should == true
        assigns(:inventory_unit).line_item.orders_store.canceled?.should == true
        assigns(:inventory_unit).line_item.orders_store.order.canceled?.should == true
      end
      
    end
    
    describe "send email" do
      
      it "should send an email that items have been canceled" do
        set_merchant(controller)
        @inventory_unit = Factory.custom_inventory_unit(:solo_inventory_unit, :store => @store)
        return_mailer = OrderMailer.cancel_email(@inventory_unit.order)
        OrderMailer.should_receive(:cancel_email).and_return(return_mailer)
        put :cancel, :id => @inventory_unit.id, :store_id => @store
      end
    end
    
  end
  
  describe "#confirm_force_cancel" do
    
    context "with merchant" do
      
      it "should not render confirm_force_cancel" do
        set_merchant(controller)
        @inventory_unit = Factory.custom_inventory_unit(:solo_inventory_unit, :store => @store)
        get :confirm_force_cancel, :id => @inventory_unit.id, :store_id => @store
        response.should_not render_template("confirm_force_cancel")
      end
      
    end
    
    context "with admin" do
      
      before :each do
        set_admin(controller)
        @store = FactoryGirl.create(:store)
        @inventory_unit = Factory.custom_inventory_unit(:solo_inventory_unit, :store => @store)
        get :confirm_force_cancel, :id => @inventory_unit.id, :store_id => @store
      end
      
      it "should set @inventory_unit and render confirm_force_cancel" do
        assigns(:inventory_unit).should == @inventory_unit
        response.should render_template("confirm_force_cancel")
      end
      
    end
    
  end
  
  describe "#force_cancel" do
    
    context "with a merchant" do
      
      it "should not cancel the inventory unit with a merchant" do
        set_merchant(controller)
        @inventory_unit = Factory.custom_inventory_unit(:shipped_inventory_unit, :store => @store)
        put :force_cancel, :id => @inventory_unit.id, :store_id => @store
        assigns(:inventory_unit).canceled?.should_not == true
      end
      
    end
    
    describe "success" do
      
      before :each do
        set_admin(controller)
        @store = FactoryGirl.create(:store)
        @inventory_unit = Factory.custom_inventory_unit(:shipped_inventory_unit, :store => @store)
        put :force_cancel, :id => @inventory_unit.id, :store_id => @store
      end
      
      it "should set the inventory unit" do
        assigns(:inventory_unit).should == @inventory_unit
      end
      
      it "should have the inventory set to canceled" do
        assigns(:inventory_unit).canceled?.should == true
      end
      
      it "should set the success flash message" do
        flash[:success].should_not be_nil
      end
      
      it "should redirect to the merchant store order page" do
        response.should redirect_to(edit_merchant_store_order_path(@store, @inventory_unit.order))
      end
      
    end
    
    describe "integration chain on force cancel" do
      
      before :each do
        set_admin(controller)
        @store = FactoryGirl.create(:store)
        @inventory_unit = Factory.custom_inventory_unit(:shipped_sole_inventory_unit, :store => @store)
        puts "inventory units are #{@inventory_unit.order.inventory_units}"
        puts "inventory units are #{@inventory_unit.order.shipments}"
        puts "inventory unit #{@inventory_unit.inspect}"
        put :force_cancel, :id => @inventory_unit.id, :store_id => @store
      end
      
      it "should set the chain to canceled when there is only one inventory unit" do
        response.should redirect_to(edit_merchant_store_order_path(@store, @inventory_unit.order))
        assigns(:inventory_unit).canceled?.should == true
        assigns(:inventory_unit).shipment.canceled?.should == true
        assigns(:inventory_unit).line_item.canceled?.should == true
        assigns(:inventory_unit).line_item.orders_store.canceled?.should == true
        assigns(:inventory_unit).line_item.orders_store.order.canceled?.should == true
      end
      
    end
    
    describe "send email" do
      
      it "should send an email that items have been canceled" do
        set_admin(controller)
        @store = FactoryGirl.create(:store)
        @inventory_unit = Factory.custom_inventory_unit(:solo_inventory_unit, :store => @store)
        return_mailer = OrderMailer.cancel_email(@inventory_unit.order)
        OrderMailer.should_receive(:cancel_email).and_return(return_mailer)
        put :force_cancel, :id => @inventory_unit.id, :store_id => @store
      end
      
    end
    
  end
  
  describe "#load_objects" do
    
    before :each do
      set_merchant(controller)
      @inventory_unit = Factory.custom_inventory_unit(:solo_inventory_unit, :store => @store)
      controller.instance_variable_set(:@inventory_unit, @inventory_unit)
      controller.stub!(:params).and_return({ :store_id => @store })
      controller.send :load_objects
    end
    
    it "should set @store" do
      assigns(:store).should == @inventory_unit.variant.product.store
    end
    
    it "should set @order" do
      assigns(:order).should == @inventory_unit.order
    end
    
  end
  
end

