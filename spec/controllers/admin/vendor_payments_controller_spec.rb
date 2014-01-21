require 'spec_helper'

describe Admin::VendorPaymentsController do
  
  describe "#new" do
    
    it "should set the proper variables and render the confirm_payment template" do
      set_admin(controller)
      @vendor_payment_period = FactoryGirl.create(:payable_vendor_payment_period)
      get :new, :vendor_payment_period_id => @vendor_payment_period, use_route: 'spree'
      assigns(:vendor_payment_period).should == @vendor_payment_period
      response.should render_template('new')
    end
    
  end
  
  describe "#create" do
    
    it "should update the payment to be queued, set the amount, and add a transaction number" do
      set_admin(controller)
      scenarios = [{:total => 100.00, :payment_total => 0.00, :amount => 100.00},
                    {:total => 100.00, :payment_total => 120.00, :amount => -20.00},
                    {:total => 100.00, :payment_total => 40.00, :amount => 60.00}]
      
      scenarios.each do |scenario|
        @vendor_payment_period = FactoryGirl.create(:payable_vendor_payment_period, :total => scenario[:total], :payment_total => scenario[:payment_total])
        @vendor_payment = FactoryGirl.create(:vendor_payment, :amount => scenario[:payment_total], :state => 'settled', :vendor_payment_period => @vendor_payment_period)
        post_params = {:vendor_payment => {:amount => scenario[:amount]}, :vendor_payment_period_id => @vendor_payment_period.id, use_route: 'spree' }
        post :create, post_params
        assigns(:vendor_payment).errors.empty?.should == true
        assigns(:vendor_payment).should be_a_kind_of(VendorPayment)
        assigns(:vendor_payment).amount.should == scenario[:amount]
        assigns(:vendor_payment_period).should == @vendor_payment_period
        assigns(:vendor_payment).vendor_payment_period.should == @vendor_payment_period
        assigns(:vendor_payment).vendor_payment_period.to_pay.should == 0
        assigns(:vendor_payment).vendor_payment_period.paid?.should == true
        response.should redirect_to(admin_vendor_payment_periods_path)
      end

    end
    
  end
  
  describe "#index" do
    
    it "should set the proper variables and render the index template" do
      set_admin(controller)
      20.times do
        FactoryGirl.create(:vendor_payment)
      end
      get :index, use_route: 'spree'
      assigns(:vendor_payments).size.should == 15
      response.should render_template("index")
    end
    
  end
  
  #describe "#show" do
  #  
  #  it "should set the proper variables and render the show template" do
  #    get :show, :id => @vendor_payment
  #    assigns(:vendor_payment).should == @vendor_payment
  #    response.should render_template("show")
  #  end
  #  
  #end
  
end
