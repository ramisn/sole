require 'spec_helper'

describe Spree::Admin::PaymentsController do
  
  describe "#refunds_payable" do
    
    before :each do
      set_admin(controller)
      get :refunds_payable, use_route: 'spree'
    end
    
    it "should assign @orders" do
      assigns(:orders)
    end
    
    it "should have each order be one where the status is credit_owed" do
      assigns(:orders).each do |order|
        order.credit_owed?.should == true
      end
    end
    
    it "should render the index template" do
      response.should render_template("refunds_payable")
    end
    
  end
  
  describe "#new_refund" do
    
    before :each do
      set_admin(controller)
      @order = Factory.custom_order(:credit_owed => true)
      get :new_refund, :order_id => @order.number, use_route: 'spree'
    end
    
    it "should assign an @order" do
      assigns(:order)
    end
    
    it "should have @order be of status credit_owed" do
      assigns(:order).payment_state.should == 'credit_owed'
    end
    
    it "should assign an @payment" do
      assigns(:payment)
    end
    
    it "should render the confirm_refund template" do
      response.should render_template("new_refund")
    end
    
  end
  
  describe "#create_refund" do
    
    before :each do
      set_admin(controller)
      @order = Factory.custom_order(:credit_owed => true)
      post :create_refund, :order_id => @order.number, use_route: 'spree'
    end
    
    it "should create the refund" do
      assigns(:payment)
    end
    
    it "should redirect to refunds_payable" do
      response.should redirect_to(refunds_payable_admin_payments_path)
    end
    
  end
  
  describe "#refunds_paid" do
    
    before :each do 
      set_admin(controller)
      get :refunds_paid, use_route: 'spree'
    end
    
    it "should assign @payments" do
      assigns(:payments)
    end
    
    it "should render the paid template" do
      response.should render_template("refunds_paid")
    end
    
  end
  
end
