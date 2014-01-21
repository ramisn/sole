require 'spec_helper'

describe VendorPayment do
  
  context "shoulda validations" do
    it { should belong_to(:vendor_payment_period) }
  end
  
  describe "#pay!" do
    
    context "success" do
      
      before :each do
        @payment = FactoryGirl.create(:vendor_payment)
        @payment.stub!(:amount).and_return(100.0)
        #@payment.update_attribute_without_callbacks 'amount', 100.0
        #@payment.vendor_payment_period.stub!(:total).and_return(100.00)
        @payment.vendor_payment_period.update_attributes_without_callbacks 'total' => 100.0, 'state' => 'payable'
        # now execute
        @payment.pay!
      end
      
      it { @payment.errors.empty?.should == true }
      it { @payment.pending?.should == true }
      it { @payment.response_code.should be_a_kind_of(String) }
      it { @payment.vendor_payment_period.paid?.should == true }
      
    end
    
    context "no payment method found" do
      
      before :each do
        @payment = FactoryGirl.create(:ready_vendor_payment)
        @payment.vendor_payment_period.store.stub!(:usa_epay_customer_number).and_return('577901')
        @payment.update_attribute_without_callbacks 'amount', 100.0
        @payment.vendor_payment_period.update_attribute_without_callbacks 'total', 100.0
        # now execute
        @payment.pay!
      end
      
      it { @payment.errors.empty?.should == false }
      it { @payment.ready?.should == true }
      it { @payment.response_code.should be_nil }
      it { @payment.vendor_payment_period.payable?.should == false }
      
    end
    
  end
  
  describe "#states" do
    
    before :all do
      @state_hash = {}
      VendorPayment.state_machines[:state].states.each {|state| @state_hash[state.name] = state.name}
    end
    
    # http://wiki.usaepay.com/developer/statuscodes
    #http://stackoverflow.com/questions/3047630/rails-how-to-test-state-machine
    it { @state_hash.has_key?(:queued).should == true }
    it { @state_hash.has_key?(:pending).should == true }
    it { @state_hash.has_key?(:submitted).should == true }
    it { @state_hash.has_key?(:funded).should == true }
    it { @state_hash.has_key?(:settled).should == true }
    it { @state_hash.has_key?(:error).should == true }
    it { @state_hash.has_key?(:voided).should == true }
    it { @state_hash.has_key?(:returned).should == true }
    it { @state_hash.has_key?(:timed_out).should == true }
    it { @state_hash.has_key?(:manager_approval).should == true }
    
  end
  
  context "class methods" do
    
    describe "#parse_statuses" do
      
      before :each do
        csv_string = CSV.generate(:force_quotes => true) do |csv|
          csv << ["Date & Time", "Transaction ID", "Billing Company", "Customer #", "Amount", "Status", "Error Message", "Batch ID", "Invoice", "Error Code", nil]
          csv << ["", "48641325", "", "", "", "N", "", "", "", "", nil]
          csv << ["", "48641325", "", "", "", "P", "", "", "", "", nil]
          csv << ["", "48641325", "", "", "", "F", "", "", "", "", nil]
          csv << ["", "48641325", "", "", "", "S", "", "", "", "", nil]
          csv << ["", "48641325", "", "", "", "S", "", "", "", "", nil]
          csv << ["", "48641325", "", "", "", "E", "", "", "", "", nil]
          csv << ["", "48641325", "", "", "", "R", "", "", "", "", nil]
          csv << ["", "48641325", "", "", "", "T", "", "", "", "", nil]
          csv << ["", "48641325", "", "", "", "M", "", "", "", "", nil]
        end

        @response = VendorPayment.parse_statuses(csv_string)
      end
      
      it { @response.should be_a_kind_of(Hash) }
      it { @response['queued'].size.should == 1 }
      it { @response['pending'].size.should == 1 }
      it { @response['submitted'].size.should == 0 }
      it { @response['funded'].size.should == 1 }
      it { @response['settled'].size.should == 2 }
      it { @response['error'].size.should == 1 }
      it { @response['voided'].size.should == 0 }
      it { @response['returned'].size.should == 1 }
      it { @response['timed_out'].size.should == 1 }
      it { @response['manager_approval'].size.should == 1 }
      
    end
    
    describe "#update_statuses" do
      
      before :each do
        @response = {
          'queued' => [FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "111").response_code],
          'pending' => [],
          'submitted' => [FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "222").response_code],
          'funded' => [FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "333").response_code, FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "555").response_code],
          'settled' => [FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "444").response_code],
          'error' => [],
          'voided' => [FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "666").response_code],
          'returned' => [FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "777").response_code],
          'timed_out' => [],
          'manager_approval' => [FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "888").response_code]
        }
        # stub pieces that call the api
        @gateway = VendorPayment.gateway
        @gateway.stub!(:get_report).and_return(ActiveMerchant::Billing::Response.new(true, ""))
        VendorPayment.stub!(:gateway).and_return(@gateway)
        VendorPayment.stub!(:parse_statuses).and_return(@response)
        
        VendorPayment.update_statuses
      end
      
      it { VendorPayment.where(:response_code => @response['queued']).queued.count.should == 1 }
      it { VendorPayment.where(:response_code => @response['pending']).pending.count.should == 0 }
      it { VendorPayment.where(:response_code => @response['submitted']).submitted.count.should == 1 }
      it { VendorPayment.where(:response_code => @response['funded']).funded.count.should == 2 }
      it { VendorPayment.where(:response_code => @response['settled']).settled.count.should == 1 }
      it { VendorPayment.where(:response_code => @response['error']).error.count.should == 0 }
      it { VendorPayment.where(:response_code => @response['voided']).voided.count.should == 1 }
      it { VendorPayment.where(:response_code => @response['returned']).returned.count.should == 1 }
      it { VendorPayment.where(:response_code => @response['timed_out']).timed_out.count.should == 0 }
      it { VendorPayment.where(:response_code => @response['manager_approval']).manager_approval.count.should == 1 }
      
    end
    
    describe "#update_vendor_payment_periods" do
      
      before :each do
        chargebackable = Factory.custom_vendor_payment_period(:state => 'chargeback_required', :merchant => 'Nooka', :month => 11, :year => 2011, :num_orders => 3, :total => 300.00, :payment_total => 350.00, :paid => Time.new(2011, 12, 15, 10, 0, 0))
        chargeback_vendor_payment = FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "11111", :vendor_payment_period => chargebackable, :amount => -50.00)
        @response = {
          'queued' => [FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "111").response_code],
          'pending' => [],
          'submitted' => [FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "222").response_code],
          'funded' => [FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "333").response_code, FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "555").response_code],
          'settled' => [FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "444").response_code],
          'error' => [],
          'voided' => [chargeback_vendor_payment.response_code, FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "666").response_code],
          'returned' => [FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "777").response_code],
          'timed_out' => [],
          'manager_approval' => [FactoryGirl.create(:vendor_payment, :state => 'ready', :response_code => "888").response_code]
        }
        # stub pieces that call the api
        @gateway = VendorPayment.gateway
        @gateway.stub!(:get_report).and_return(ActiveMerchant::Billing::Response.new(true, ""))
        VendorPayment.stub!(:gateway).and_return(@gateway)
        VendorPayment.stub!(:parse_statuses).and_return(@response)
        
        VendorPayment.update_statuses
        
        # stub pieces that call the database
        #VendorPayment.stub!(:gateway).and_return(@gateway)
        #ActiveRecord::Relation.any_instance.stub(:update_all)
        #VendorPayment.stub!(:where).and_return(ActiveRecord::Relation.new)
        VendorPayment.update_vendor_payment_periods(@response)
      end
      
      it { VendorPaymentPeriod.chargeback_required.count.should == 1 }
      it { VendorPaymentPeriod.chargeback_required.count.should == VendorPaymentPeriod.payment_chargeback_required.count }
      it "should have the same chargeback_required sets" do
        cr = VendorPaymentPeriod.chargeback_required
        pcr = VendorPaymentPeriod.payment_chargeback_required
        size = cr.count
        
        counter = 0
        while counter < size
          cr[counter].should == pcr[counter]
          
          counter += 1
        end
      end
      
      it { VendorPaymentPeriod.paid.count.should == 6 }
      it { VendorPaymentPeriod.paid.count.should == VendorPaymentPeriod.payment_paid.count }
      it "should have the same paid sets" do
        paid = VendorPaymentPeriod.paid
        pp = VendorPaymentPeriod.payment_paid
        size = paid.count
        
        counter = 0
        while counter < size
          paid[counter].should == pp[counter]
          
          counter += 1
        end
      end
      
      it { VendorPaymentPeriod.payable.count.should == 2 }
      it { VendorPaymentPeriod.payable.count.should == VendorPaymentPeriod.payment_payable.count }
      it "should have the same payable sets" do
        pay = VendorPaymentPeriod.payable
        pp = VendorPaymentPeriod.payment_payable
        size = pay.count
        
        counter = 0
        while counter < size
          pay[counter].should == pp[counter]
          
          counter += 1
        end
      end
      
      
    end
    
    describe "#gateway" do
      
      before :each do
        @gateway = VendorPayment.gateway
      end
      
      it { @gateway.should be_a_kind_of(ActiveMerchant::Billing::UsaEpayAdvancedGateway) }
      it { @gateway.options[:login].should == USA_EPAY_SOURCE_KEY }
      it { @gateway.options[:software_id].should == USA_EPAY_SOFTWARE_ID }
      it { @gateway.options[:password].should == USA_EPAY_PIN }
      
    end

  end
  
  #context "private methods" do
  #  
  #  describe "#generate_soap_server" do
  #    
  #    it "create a soap server with the proper endpoint url"
  #    
  #  end
  #  
  #  describe "#generate_transaction_request" do
  #    
  #    it "should create a transaction request with proper transaction detail"
  #    
  #  end
  #  
  #end
  
end
