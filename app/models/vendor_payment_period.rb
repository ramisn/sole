class VendorPaymentPeriod < ActiveRecord::Base
  has_many :vendor_payments
  has_many :orders_stores
  belongs_to :store
  
  scope :beginning_month, lambda {|year, month| where('vendor_payment_periods.month >= ?', Time.new(year, month).to_date)}
  scope :ending_month, lambda {|year, month| where('vendor_payment_periods.month <= ?', Time.new(year, month).to_date)}
  scope :within_month, lambda {|year, month| where(:month => Time.new(year, month).to_date)}
  scope :inactive, where(:state => :inactive)
  scope :chargeback_required, where(:state => :chargeback_required)
  scope :paid, where(:state => :paid)
  scope :payable, where(:state => :payable)
  scope :payment_chargeback_required, where('vendor_payment_periods.payment_total > vendor_payment_periods.total')
  scope :payment_paid, where('vendor_payment_periods.payment_total = vendor_payment_periods.total')
  scope :payment_payable, where('vendor_payment_periods.payment_total < vendor_payment_periods.total')
  
  state_machine :initial => :inactive do
    
    event :activate do
      transition :inactive => :payable
    end
    
    event :pay do
      transition :payable => :paid, :if => :total_is_payment_total?
    end
    
    event :refund_occured do
      transition [:paid, :payable] => :chargeback_required, :if => :total_less_than_payment_total?
      transition [:paid, :chargeback_required] => :payable, :if => :total_greater_than_payment_total?
    end
    
    event :chargedback do
      transition :chargeback_required => :paid, :if => :total_is_payment_total?
      transition :chargeback_required => :payable, :if => :total_greater_than_payment_total?
    end
    
  end
  
  def inventory_units
    InventoryUnit.joins([{:order => :orders_stores}, :shipment]).where(:order => {:orders_stores => {:vendor_payment_period_id => self.id}}, :shipments => {:store_id => self.store_id})
  end
  
  def line_items
    LineItem.joins(:order => :orders_stores).where(:order => {:orders_stores => {:vendor_payment_period_id => self.id}}, :store_id => self.store_id)
  end
  
  def shipping_charges
    Adjustment.shipping.joins(:order => :orders_stores).where(:order => {:orders_stores => {:vendor_payment_period_id => self.id}}).joins('INNER JOIN shipments ON adjustments.source_id=shipments.id').where('shipments.store_id=?', self.store_id)
  end
  
  def coupons_applied
    PromotionCredit.joins({:order => :orders_stores}).where(:order => {:orders_stores => {:vendor_payment_period_id => self.id}}, :source_type => 'Promotion')
  end
  
  def to_pay
    total - payment_total
  end
  
  def total_is_payment_total?
    self.total == self.payment_total
  end
  
  def total_greater_than_payment_total?
    self.total > self.payment_total
  end
  
  def total_less_than_payment_total?
    self.total < self.payment_total
  end
  
  def update_total!
    self.update_attribute_without_callbacks 'total', self.orders_stores.sum(:total_reimbursement)
  end
  
  def update_payment_total!
    self.update_attribute_without_callbacks 'payment_total', self.vendor_payments.not_failed.sum(:amount)
  end
  
  def update_state!
    amount_to_pay = to_pay
    update_attribute_without_callbacks 'state', if amount_to_pay < 0
      'chargeback_required'
    elsif amount_to_pay > 0
      'payable'
    else
      'paid'
    end
  end
  
  class << self
    
    def check_orders_store_for_period(orders_store)
      if orders_store.completed_at
        new_month = Time.utc(orders_store.completed_at.year, orders_store.completed_at.month)
        vendor_payment_period = self.where(:store_id => orders_store.store, :month => new_month).limit(1).first
        if vendor_payment_period.nil?
          vendor_payment_period = self.create(:store => orders_store.store, :month => new_month)
        end
        orders_store.update_attribute_without_callbacks :vendor_payment_period_id, vendor_payment_period
        vendor_payment_period.update_total!
        vendor_payment_period
      elsif orders_store.vendor_payment_period
        vendor_payment_period = orders_store.vendor_payment_period
        orders_store.update_attribute_without_callbacks :vendor_payment_period_id, nil
        vendor_payment_period.update_total!
        orders_store
      end
    end
    
    def get_payment_periods_ready
      now = Time.now
      if now.day == 15
        last_month = now - 1.month
        self.within_month(last_month.year, last_month.month).update_all(:state => 'payable')
        
      ####
      # The following is a hack because on the production server, all payment periods are for some reason being
      # flagged as payable if they haven't been paid yet, even though they're properly flagged on the staging servers.
      ####
      elsif now.day < 15
        # set current month as not payable
      end
      # set current month as not payable
      
    end
    
  end
end
