require 'spec_helper'

describe Merchant::VendorPaymentsController do
  
  describe "#index" do
    
    it "should set the proper variables and render the index template" do
      set_merchant(controller)
      10.times do |i|
        FactoryGirl.create(:vendor_payment, :vendor_payment_period => FactoryGirl.create(:vendor_payment_period, :store => @store, :month => Time.new(2011, i+1).to_date))
      end
      get :index, :store_id => @store
      #puts response.inspect
      response.should render_template("index")
      assigns(:vendor_payments).size.should == 10
    end
    
  end
  
end
