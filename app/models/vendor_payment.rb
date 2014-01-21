#if ENV['SERVER'] == 'shop'
#  require 'USAePay_ruby_live/usaepayDriver'
#else
#  require 'USAePay_ruby_sandbox/usaepayDriver'
#end

class VendorPayment < Spree::Payment
  belongs_to :vendor_payment_period
  belongs_to :admin, :class_name => 'Spree::User'
  
  has_many :inventory_units, :foreign_key => :vendor_payment_reversal_id # used only on payment reversals
  
  validates :admin_id, :presence => true
  validates :vendor_payment_period, :presence => true
  validates :product_sales, :presence => true
  validates :amount, :presence => true
  validates :coupons, :presence => true
  validates :shipping, :presence => true
  
  # 31 Break
  # scope :queued, where(:state => :queued)
  # scope :pending, where(:state => :pending)
  # scope :submitted, where(:state => :submitted)
  # scope :funded, where(:state => :funded)
  # scope :settled, where(:state => :settled)
  # scope :error, where(:state => :error)
  # scope :voided, where(:state => :voided)
  # scope :returned, where(:state => :returned)
  # scope :timed_out, where(:state => :timed_out)
  # scope :manager_approval, where(:state => :manager_approval)
  # scope :not_failed, where(:state => [:queued, :pending, :submitted, :funded, :timed_out, :manager_approval, :settled])
  # scope :failed, where(:state => [:error, :voided, :returned])
  # scope :outstanding, where(:state => [:queued, :pending, :submitted, :funded, :timed_out, :manager_approval])
  # scope :reversed, where('payments.amount < 0')
  
  # state_machine :initial => :ready do
  #   state :queued
  #   state :pending
  #   state :submitted
  #   state :funded
  #   state :settled
  #   state :error
  #   state :voided
  #   state :returned
  #   state :timed_out
  #   state :manager_approval
  # end
  
  def pay!
    #soap_server = VendorPayment.generate_soap_server
    #token = VendorPayment.generate_usa_epay_security_token
    #custNum = observed.vendor_payment_period.store.id
    #paymentMethodID = nil
    #parameters = generate_transaction_request
    #response = soap_server.runCustomerTransaction(token, custNum, paymentMethodID, parameters)
    #
    if self.vendor_payment_period.store.usa_epay_customer_number.blank?
      self.errors['usa_epay_customer_number'] = "The USA ePay custNum must be set before a payment can be made."
      return
    end
    gateway = VendorPayment.gateway
    payment_methods_response = gateway.get_customer_payment_methods(:customer_number => self.vendor_payment_period.store.usa_epay_customer_number)
    monthly_transfer_method = nil
    items = if payment_methods_response.params['get_customer_payment_methods_return']
      payment_methods_response.params['get_customer_payment_methods_return']['item']
    else
      []
    end
    
    if items.is_a?(Hash)
      items = [items]
    end
    
    items.each do |payment_method|
      if payment_method['method_name'].strip == 'Monthly ACH Transfer'
        monthly_transfer_method = payment_method
      end
    end
    
    if monthly_transfer_method
      response = gateway.run_customer_transaction(:customer_number => self.vendor_payment_period.store.usa_epay_customer_number,
                                                  :command => 'CheckCredit',
                                                  # USA ePay does pennies for the amount, so it needs to be
                                                  # multiplied by 100
                                                  :payment_method_id => monthly_transfer_method['method_id'],
                                                  :amount => self.amount * 100)
      
      
      self.state = if response.message['result_code'].strip == 'A'
        VendorPayment.status_codes[response.message['status_code']]
      else
        VendorPayment.status_codes["E"]
      end
      self.response_data =  YAML::dump(response)
      if !response.message['ref_num'].blank?
        self.response_code = response.message['ref_num']
        save
      else
        save
        self.errors['transaction'] = "State: #{self.state}. There was an error with code #{response.message['error_code']}, while trying to make the payment. Check USA ePay for reference number #{response.message['ref_num']} if necessary.\n\nFull Message: #{response.message.inspect}"
      end
      self.vendor_payment_period.update_payment_total!
      self.vendor_payment_period.update_state!
    else
      self.errors['payment_method'] = "There is no payment method on the vendor called 'Monthly ACH Transfer'"
    end
  end
  
  class << self
    
    def status_codes
      @status_codes ||= {
       "N" => 'queued',
       "P" => 'pending',
       "B" => 'submitted',
       "F" => 'funded',
       "S" => 'settled',
       "E" => 'error',
       "V" => 'voided',
       "R" => 'returned',
       "T" => 'timed_out',
       "M" => 'manager_approval'
      }
    end
    
    def parse_statuses(response)
      statuses = {'queued' => [],
                  'pending' => [],
                  'submitted' => [],
                  'funded' => [],
                  'settled' => [],
                  'error' => [],
                  'voided' => [],
                  'returned' => [],
                  'timed_out' => [],
                  'manager_approval' => []}
      
      csv = CSV.new(response)
      header = csv.shift
      while row = csv.shift
        statuses[status_codes[row[5]]] << row[1]
      end
      statuses
    end
    
    def update_statuses
      #soap_server = generate_soap_server
      #token = generate_usa_epay_security_token
      #report = "Vendor Payments"
      #options = nil
      #format = "CSV"
      #response = soap_server.getReport(token, report, options, format)
      response = VendorPayment.gateway.get_report(:report => 'Custom:Monthly Vendor Payments', 
                                                  :format => 'csv', 
                                                  :options => [{:field => 'StartDate', :value => '11/01/2011'}, 
                                                               {:field => 'EndDate', :value => Time.now.strftime('%m/%d/%Y')}])
      statuses = self.parse_statuses(Base64.decode64(response.message))
      statuses.each do |key, value|
        VendorPayment.where(:response_code => value).update_all(:state => key)
      end
      update_vendor_payment_periods(statuses)
    end
    
    def update_vendor_payment_periods(statuses)
      error_statuses = statuses['voided']+statuses['error']+statuses['returned']
      error_statuses.each do |response_code|
        vendor_payment_period = VendorPayment.find_by_response_code(response_code).vendor_payment_period
        vendor_payment_period.update_payment_total!
      end
      VendorPaymentPeriod.payment_chargeback_required.update_all 'state' => 'chargeback_required'
      VendorPaymentPeriod.payment_paid.update_all 'state' => 'paid'
      VendorPaymentPeriod.payment_payable.update_all 'state' => 'payable'
    end
    
    def gateway
      ActiveMerchant::Billing::UsaEpayAdvancedGateway.new(:login => USA_EPAY_SOURCE_KEY, :password => USA_EPAY_PIN, :software_id => USA_EPAY_SOFTWARE_ID)
    end
    
    #def generate_usa_epay_security_token
    #  UeSecurityToken.new(nil, nil, USA_EPAY_SOURCE_KEY)
    #end
    #
    #def generate_soap_server
    #  endpoint_url = 'https://sandbox.usaepay.com/soap/gate/131C979E'
    #  UeSoapServerPortType.new(endpoint_url)
    #end
    
  end

  private
  
  #def generate_transaction_request
  #  discount = nil
  #  shipping = nil
  #  sub_total = nil
  #  description = "description"
  #  comments = "comments"
  #  detail = TransactionDetail.new(nil, observed,vendor_payment_period.to_pay, nil, nil, 
  #                                 description, comments, discount, nil, nil, nil, nil, 
  #                                 shipping, sub_total, nil, nil, nil, nil)
  #  
  #  CustomerTransactionRequest.new("CheckCredit", nil, nil, nil, nil, nil, nil, nil, nil, nil, detail, nil, nil, nil, nil)
  #end

    def amount_is_valid_for_outstanding_balance_or_credit
    end

    def profiles_supported?
      payment_method.respond_to?(:payment_profiles_supported?) && payment_method.payment_profiles_supported?
    end

    def create_payment_profile
      return unless source.is_a?(Creditcard) && source.number && !source.has_payment_profile?
      payment_method.create_profile(self)
    rescue ActiveMerchant::ConnectionError => e
      gateway_error I18n.t(:unable_to_connect_to_gateway)
    end

    def update_order
    end
end
