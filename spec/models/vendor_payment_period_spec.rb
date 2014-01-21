require 'spec_helper'

describe VendorPaymentPeriod do
  
  context "shoulda validations" do
    it { should have_many(:orders_stores) }
    it { should have_many(:vendor_payments) }
  end
  
  context "state machine" do
    
    describe "#activate!" do
      
      it "should change to payable" do
        @vendor_payment_period = FactoryGirl.create(:vendor_payment_period)
        @vendor_payment_period.activate!
        @vendor_payment_period.payable?.should == true
      end
      
    end
    
    describe "#pay!" do
      
      context "payment_total is equal to total" do
        
        it "should change to paid if all valid payments have processed" do
          @vendor_payment_period = FactoryGirl.create(:payable_vendor_payment_period, :total => 100.00, :payment_total => 100.0)
          @vendor_payment_period.pay!
          @vendor_payment_period.paid?.should == true
        end
        
      end
      
    end
    
    describe "#refund_occured!" do
      
      it "should change to chargeback_required" do
        @vendor_payment_period = FactoryGirl.create(:paid_vendor_payment_period, :total => 100.00, :payment_total => 125.00)
        @vendor_payment_period.refund_occured!
        @vendor_payment_period.chargeback_required?.should == true
      end
      
    end
    
    describe "#chargedback!" do
      
      it "should change to paid if the total is the payment total" do
        @vendor_payment_period = FactoryGirl.create(:chargeback_vendor_payment_period, :total => 100.00, :payment_total => 100.00)
        @vendor_payment_period.chargedback!
        @vendor_payment_period.paid?.should == true
      end
      
      it "should change to payable if the total is greater than the payment total" do
        @vendor_payment_period = FactoryGirl.create(:chargeback_vendor_payment_period, :total => 125.00, :payment_total => 100.00)
        @vendor_payment_period.chargedback!
        @vendor_payment_period.payable?.should == true
      end
      
      it "should remain the same if the total is less than the payment total" do
        @vendor_payment_period = FactoryGirl.create(:chargeback_vendor_payment_period, :total => 100.00, :payment_total => 125.00)
        @vendor_payment_period.chargedback
        @vendor_payment_period.chargeback_required?.should == true
      end
      
    end
    
  end
  
  describe "#line_items" do
    
    it "should return all the line items of the vendor payment period's orders" do
      @store = FactoryGirl.create(:store)
      @vendor_payment_period = Factory.setup_store_payments(@store)
      @vendor_payment_period.line_items.each do |line_item|
        line_item.orders_store.vendor_payment_period.should == @vendor_payment_period
      end
    end
    
  end
  
  describe "#shipping_charges" do
    
    it "should return all the shipping charges for the vendor payment period's orders" do
      @store = FactoryGirl.create(:store)
      @vendor_payment_period = Factory.setup_store_payments(@store)
      @vendor_payment_period.shipping_charges.each do |shipping_charge|
        shipping_charge.order.orders_stores.where(:store_id => @store).first.vendor_payment_period.should == @vendor_payment_period
      end
    end
    
  end
  
  describe "#coupons_applied" do
    
    it "should return all the coupons applied to the vendor payment period's orders" do
      @store = FactoryGirl.create(:store)
      @vendor_payment_period = Factory.setup_store_payments(@store)
      @vendor_payment_period.coupons_applied.each do |promotion_credit|
        promotion_credit.order.orders_stores.where(:store_id => @store).first.vendor_payment_period.should == @vendor_payment_period
      end
    end
    
  end
  
  describe "#to_pay" do
    
    it "should be the payment total subtracted from the total" do
      [[100.00, 125.00, -25.00], [125.00, 100.00, 25.00], [100.00, 100.00, 0.00]].each do |values|
        @vendor_payment_period = FactoryGirl.create(:vendor_payment_period, :total => values[0], :payment_total => values[1])
        @vendor_payment_period.to_pay.should == values[2]
      end
    end
    
  end
  
  describe "#total_is_payment_total?" do
    
    it "should return true if total is equal to payment total" do
      @vendor_payment_period = FactoryGirl.create(:vendor_payment_period, :total => 100.00, :payment_total => 100.00)
      @vendor_payment_period.total_is_payment_total?.should == true
    end
    
    it "should return false if total is less than payment total" do
      @vendor_payment_period = FactoryGirl.create(:vendor_payment_period, :total => 100.00, :payment_total => 125.00)
      @vendor_payment_period.total_is_payment_total?.should == false
    end
    
    it "should return false if total is greater than payment total" do
      @vendor_payment_period = FactoryGirl.create(:vendor_payment_period, :total => 100.00, :payment_total => 75.00)
      @vendor_payment_period.total_is_payment_total?.should == false
    end
    
  end
  
  describe "#total_greater_than_payment_total?" do
    
    it "should return false if total is equal to payment total" do
      @vendor_payment_period = FactoryGirl.create(:vendor_payment_period, :total => 100.00, :payment_total => 100.00)
      @vendor_payment_period.total_greater_than_payment_total?.should == false
    end
    
    it "should return false if total is less than payment total" do
      @vendor_payment_period = FactoryGirl.create(:vendor_payment_period, :total => 100.00, :payment_total => 125.00)
      @vendor_payment_period.total_greater_than_payment_total?.should == false
    end
    
    it "should return true if total is greater than payment total" do
      @vendor_payment_period = FactoryGirl.create(:vendor_payment_period, :total => 100.00, :payment_total => 75.00)
      @vendor_payment_period.total_greater_than_payment_total?.should == true
    end
    
  end
  
  describe "#total_less_than_payment_total?" do
    
    it "should return true if total is equal to payment total" do
      @vendor_payment_period = FactoryGirl.create(:vendor_payment_period, :total => 100.00, :payment_total => 100.00)
      @vendor_payment_period.total_less_than_payment_total?.should == false
    end
    
    it "should return false if total is less than payment total" do
      @vendor_payment_period = FactoryGirl.create(:vendor_payment_period, :total => 100.00, :payment_total => 125.00)
      @vendor_payment_period.total_less_than_payment_total?.should == true
    end
    
    it "should return false if total is greater than payment total" do
      @vendor_payment_period = FactoryGirl.create(:vendor_payment_period, :total => 100.00, :payment_total => 75.00)
      @vendor_payment_period.total_less_than_payment_total?.should == false
    end
    
  end
  
  describe "#update_total!" do
    
    it "should set the payment total to the sum of the vendor payment amoumts" do
      @vendor_payment_period = FactoryGirl.create(:vendor_payment_period)
      total = 0
      3.times do |i|
        orders_store = FactoryGirl.create(:orders_store, :total_reimbursement => (i+1)*5)
        total += orders_store.total_reimbursement
      end
      @vendor_payment_period.update_total!
      @vendor_payment_period.total == total
    end
    
  end
  
  describe "#update_payment_total!" do
    
    it "should set the payment total to the sum of the vendor payment amoumts" do
      @vendor_payment_period = FactoryGirl.create(:vendor_payment_period)
      total = 0
      3.times do |i|
        payment = FactoryGirl.create(:vendor_payment, :amount => (i+1)*5, :vendor_payment_period => @vendor_payment_period)
        total += payment.amount
      end
      @vendor_payment_period.update_payment_total!
      @vendor_payment_period.payment_total == total
    end
    
    it "should be zero if all vendor payment amounts did not succeed" do
      @vendor_payment_period = FactoryGirl.create(:vendor_payment_period)
      @vendor_payment = FactoryGirl.create(:vendor_payment, :vendor_payment_period => @vendor_payment_period, :state => 'error')
      @vendor_payment_period.update_payment_total!
      @vendor_payment_period.payment_total == 0
    end
    
  end
  
  context "class methods" do
    
    describe "#check_orders_store_for_period" do
      
      before :each do
        @orders_store = FactoryGirl.create(:complete_orders_store, :completed_at => Time.new(2011, 11), :order => FactoryGirl.create(:order))
        VendorPaymentPeriod.where(:month => Time.new(2011, 11)).count.should == 0
        @vendor_payment_period = VendorPaymentPeriod.check_orders_store_for_period(@orders_store)
        @orders_store.reload
      end
      
      it "should create a new payment period if none exists" do
        @vendor_payment_period.id.should be_a_kind_of(Fixnum)
      end
      
      it "should add the orders store to the payment period" do
        @vendor_payment_period.orders_stores.where(:id => @orders_store).should_not be_nil
      end
      
      it "should recalculate the total for the payment period" do
        @vendor_payment_period.total.should == @orders_store.total_reimbursement
      end
      
    end
    
    describe "#get_payment_periods_ready" do
      
      it "should set all payment periods that occured in the previous month to ready, when it is the 15th" do
        @vendor_payment_period_before = FactoryGirl.create(:paid_vendor_payment_period, :month => Time.new(2011,11,10))
        @vendor_payment_period = FactoryGirl.create(:vendor_payment_period, :month => Time.new(2011, 11))
        @vendor_payment_period_after = FactoryGirl.create(:vendor_payment_period, :month => Time.new(2011, 12))
        Time.stub!(:now).and_return(Time.new(2011, 12, 15))
        VendorPaymentPeriod.get_payment_periods_ready
        @vendor_payment_period.reload
        VendorPaymentPeriod.paid.size.should == 1
        VendorPaymentPeriod.paid.first.should == @vendor_payment_period_before
        VendorPaymentPeriod.payable.size.should == 1
        VendorPaymentPeriod.payable.first.should == @vendor_payment_period
        VendorPaymentPeriod.inactive.size.should == 1
        VendorPaymentPeriod.inactive.first.should == @vendor_payment_period_after
      end
      
    end
    
  end
  
end
