class OrdersStore < ActiveRecord::Base
  belongs_to :order, :class_name => "Spree::Order"
  belongs_to :store
  belongs_to :vendor_payment_period
  
  scope :inactive, where(:state => 'inactive')
  scope :active, where('orders_stores.state!=?', 'inactive')
  scope :open, where(:state => ['open', 'past_due'])
  scope :still_open, where(:state => ['open', 'past_due'])
  scope :past_due, where(:state => 'past_due')
  scope :complete, where(:state => ['complete', 'closed_late'])
  scope :closed_late, where(:state => 'closed_late')
  scope :canceled, where(:state => 'canceled')
  scope :coupons_applied, where('orders_stores.coupons < 0')
  
  ###
  # For easily accessing the order data
  ###
  def number
    self.order.number
  end
  
  def email
    self.order.email
  end
  
  def ship_address
    self.order.ship_address
  end
  
  def bill_address
    self.order.bill_address
  end
  
  def user
    self.order.user
  end
  
  def line_items
    self.order.line_items.by_store(self.store)
  end
  
  def line_item_promotion_credits
    self.line_items.includes(:line_item_promotion_credits).collect do |line_item|
      line_item.line_item_promotion_credits
    end.flatten.delete_if { |lipc| lipc.nil? }
  end
  
  def shipments
    self.order.shipments.by_store(self.store)
  end
  
  def inventory_units
    Spree::InventoryUnit.where(:line_item_id => self.line_items)
  end

  def remaining_to_ship
    self.inventory_units.not_shipped.not_canceled
  end
 
  #def method_missing(*args)
  #  if self.order.class.method_defined?(args[0].to_sym)
  #    self.order.send(*args)
  #  else
  #    super
  #  end
  #end
  
  def open_shipment_late?
    self.shipments.not_shipped.each do |shipment|
      if shipment.late?
        return true
      end
    end
    false
  end
  
  def all_shipped_on_time?
    return false if self.shipments.count == 0
    self.shipments.each do |shipment|
      if !shipment.shipped? or shipment.late?
        return false
      end
    end
    true
  end
  
  def all_shipped?
    return false if self.shipments.count == 0
    self.shipments.each do |shipment|
      if !shipment.shipped?
        return false
      end
    end
    true
  end
  
  def all_items_canceled?
    #puts "os self is #{self.inspect}"
    #puts " line items not canceled #{self.line_items.not_canceled.count} #{self.line_items.not_canceled.all}"
    self.line_items.not_canceled.count == 0
  end
  
  def none_shipped?
    self.inventory_units.shipped.count == 0
  end
  
  def shipped?
    self.state == 'complete' || self.state == 'closed_late'
  end
  
  def on_time?
    return false if self.shipments.shipped.count == 0
    self.shipments.shipped.each do |shipment|
      if shipment.late?
        return false
      end
    end
    true
  end
  
  state_machine :initial => 'inactive', :use_transactions => false do
    
    event :ready do
      transition :from => 'inactive', :to => 'open'
    end
    
    event :check_if_late do
      transition :from => 'open', :to => 'past_due', :if => :open_shipment_late?
    end
    
    event :shipped do
      transition :from => 'open', :to => 'complete', :if => :all_shipped_on_time?
      transition :from => 'open', :to => 'closed_late', :if => :all_shipped?
      transition :from => 'past_due', :to => 'closed_late', :if => :all_shipped?
    end
    
    event :cancel_remaining do
      transition :from => ['open', 'past_due'], :to => 'canceled', :if => :none_shipped?
      transition :from => ['open'], :to => 'complete', :if => :on_time?
      transition :from => ['open', 'past_due'], :to => 'closed_late'
    end
    
    event :cancel do
      transition :from => ['open', 'past_due', 'complete', 'closed_late'], :to => 'canceled', :if => :all_items_canceled?
      transition :from => ['open'], :to => 'complete', :if => :all_shipped_on_time?
      transition :from => ['open', 'past_due'], :to => 'closed_late', :if => :all_shipped?
    end
    
    event :force_cancel do
      transition :to => 'canceled'
    end
    
  end
  
  def calculate!
    calculate_line_items!
    calculate_product_sales!
    calculate_product_reimbursement!
    calculate_shipping!
    calculate_coupons!
    calculate_store_coupons!
    calculate_total_amount!
    calculate_total_reimbursement!
    self.save
    if vendor_payment_period
      vendor_payment_period.update_total!
      vendor_payment_period.update_state! if !vendor_payment_period.inactive?
    end
  end
  
  private
  
  ###
  # Calculating
  ###
  
  def calculate_line_items!
    self.line_items.each {|line_item| line_item.calculate!}
  end
  
  def calculate_product_sales!
    self.product_sales = self.line_items.map(&:amount).sum
  end
  
  def calculate_product_reimbursement!
    self.product_reimbursement = self.line_items.sum(:store_amount)
  end
  
  def calculate_shipping!
    self.shipping = Soletron::ShipmentCalculator.compute(self.order, self.store)
  end
  
  def calculate_lipc_coupons
    self.line_item_promotion_credits.map(&:amount).sum
  end

  def calculate_lipc_store_coupons
    self.line_item_promotion_credits.map(&:store_amount).sum
  end
  
  # Right now it will only allocate if the free shipping adjustments for the order
  # are the same as the amount of shipping for the order, which assumes the user
  # used a site-wide free shipping coupon.
  #
  # If later stores are to be allowed to provide free shipping for just purchases
  # from their stores or for one of their products, then this will need to be rewriten
  # such that it properly calculates and accounts for those scenarios.
  def calculate_free_shipping_coupons
    return self.shipping if order.shipping_total == order.free_shipping_coupon_total
    0
  end

  def product_sales_proportion
    self.product_sales / order.item_total
  end
  
  # This calculates coupons for non-free shipping and non-lipc promotions
  def calculate_other_coupons
    return 0 if order.item_total == 0
    
    coupon_adjustment = product_sales_proportion
    self.order.not_free_shipping_nor_lipc_promotions.map do |credit|
      credit.amount * coupon_adjustment
    end.sum
  end
  
  def calculate_coupons!
    self.coupons = if self.order.item_total != 0
      if self.product_sales != 0
        calculate_free_shipping_coupons + calculate_lipc_coupons + calculate_other_coupons
      else
        0
      end
    else
      self.product_sales * -1
    end
  end

  def calculate_store_coupons!
    self.coupons = if self.order.item_total != 0
      if self.product_reimbursement != 0
      ((calculate_free_shipping_coupons + calculate_lipc_store_coupons + (calculate_other_coupons * self.product_reimbursement / self.product_sales) - 0.005) * 100).to_i / 100.0
      else
        0
      end
    else
      self.product_reimbursement * -1
    end
  end

  def calculate_total_amount!
    self.total_amount = self.product_sales + self.shipping + self.coupons # (self.order.coupon_total * (self.order.item_total != 0 ? self.product_sales / self.order.item_total : 0))
  end
  
  # adjust coupons based-on the product reimbursement % so that the coupon costs are shared equally based-on
  # the commission amount soletron takes
  def calculate_total_reimbursement!
    self.total_reimbursement = self.product_reimbursement + self.shipping + self.coupons
  end
end
