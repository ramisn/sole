require 'spec_helper'

describe Merchant::VendorPaymentPeriodsController do
  
  describe "#index" do
    
    it "should set the proper variables and render the index template" do
      set_merchant(controller)
      10.times do |i|
        FactoryGirl.create(:vendor_payment_period, :store => @store, :month => Time.new(2011, i+1).to_date)
      end
      get :index, :store_id => @store
      response.should render_template("index")
      assigns(:vendor_payment_periods).size.should == 10
    end
    
  end
  
  describe "#show" do
    
    it "should set the proper variables and render the show template" do
      set_merchant(controller)
      @vendor_payment_period = FactoryGirl.create(:vendor_payment_period, :store => @store)
      get :show, :id => @vendor_payment_period, :store_id => @store
      assigns(:vendor_payment_period).should == @vendor_payment_period
      response.should render_template("show")
    end
    
  end
  
  describe "#line_items_data" do
    
    it "should return a parseable csv file" do
      set_merchant(controller)
      @vendor_payment_period = Factory.setup_store_payments(@store)
      get :line_items_data, :id => @vendor_payment_period, :store_id => @store, :format => :csv
      assigns(:vendor_payment_period).should == @vendor_payment_period
      assigns(:line_items).should_not be_nil
      response.body.should be_a_kind_of(String)
      CSV.parse(response.body).should_not be_nil
    end
    
  end
  
  describe "#shipping_data" do
    
    it "should return a parseable csv file" do
      set_merchant(controller)
      @vendor_payment_period = Factory.setup_store_payments(@store)
      get :shipping_data, :id => @vendor_payment_period, :store_id => @store, :format => :csv
      assigns(:vendor_payment_period).should == @vendor_payment_period
      assigns(:shipping_charges).should_not be_nil
      response.body.should be_a_kind_of(String)
      CSV.parse(response.body).should_not be_nil
    end
    
  end
  
  describe "#coupons_data" do
    
    it "should return a parseable csv file" do
      set_merchant(controller)
      @vendor_payment_period = Factory.setup_store_payments(@store)
      get :coupons_data, :id => @vendor_payment_period, :store_id => @store, :format => :csv
      assigns(:vendor_payment_period).should == @vendor_payment_period
      assigns(:orders_stores).should_not be_nil
      response.body.should be_a_kind_of(String)
      CSV.parse(response.body).should_not be_nil
    end
    
  end
  
end

