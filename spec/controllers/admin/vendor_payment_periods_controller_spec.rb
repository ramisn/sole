require 'spec_helper'

describe Admin::VendorPaymentPeriodsController do
  
  describe "#index" do
    
    it "should set the proper variables and render the index template" do
      set_admin(controller)
      20.times do
        vpp = FactoryGirl.create(:vendor_payment_period)
      end
      get :index, use_route: 'spree'
      assigns(:vendor_payment_periods).size.should == 15
      response.should render_template("index")
    end
    
  end
  
end

