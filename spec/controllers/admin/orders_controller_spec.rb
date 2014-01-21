require 'spec_helper'

describe Spree::Admin::OrdersController do
  
  describe "#confirm_force_cancel" do
    
    before :each do
      set_admin(controller)
      @order = FactoryGirl.create(:complete_shipped_order)
      get :confirm_force_cancel, :id => @order.number, use_route: 'spree'
    end
    
    it "should assign @orders_store and @order and @store" do
      assigns(:order).should == @order
    end
    
    it "should render the confirm_cancel template" do
      response.should render_template("confirm_force_cancel")
    end
    
  end
  
  describe "#force_cancel" do
    
    describe "#success" do
      
      before :each do
        set_admin(controller)
        @order = FactoryGirl.create(:complete_shipped_order)
        put :force_cancel, :id => @order.number, use_route: 'spree'
      end
      
      it "should assign @orders_store" do
        assigns(:order).should == @order
      end
      
      it "should set all of the non-shipped inventory units to canceled" do
        assigns(:order).inventory_units.each do |inventory_unit|
          inventory_unit.canceled?.should == true
        end
      end
      
      it "should redirect back to the order edit page on success" do
        response.should redirect_to(admin_orders_path)
      end
      
    end
    
    describe "send email" do
      
      it "should send an email that items have been canceled" do
        set_admin(controller)
        @order = FactoryGirl.create(:complete_shipped_order)
        return_mailer = Spree::OrderMailer.cancel_email(@order)
        Spree::OrderMailer.should_receive(:cancel_email).and_return(return_mailer)
        put :force_cancel, :id => @order.number, use_route: 'spree'
      end
      
    end
    
  end
  
end
