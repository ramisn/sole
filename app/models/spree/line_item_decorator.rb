Spree::LineItem.class_eval do
  
  belongs_to :store
  
  has_many :inventory_units
  
  has_many :line_item_promotion_credits
  has_many :promotion_credits, :through => :line_item_promotion_credits
  
  skip_callback :save, :after, :update_inventory
  
  scope :by_store, lambda {|store_id| where(:store_id => store_id)}
  scope :by_order, lambda {|order_id| where(:order_id => order_id)}
  scope :closed, where("spree_line_items.state LIKE 'closed'")
  scope :open, where(:state => 'open')
  scope :past_due, where(:state => 'past_due')
  scope :open_and_past_due, where("spree_line_items.state IN ('open', 'past_due')")
  scope :canceled, where(:state => 'canceled')
  scope :not_canceled, where("spree_line_items.state != ?", 'canceled')
  scope :closed_late, where(:state => 'closed_late')
  scope :except_ready, where("spree_line_items.state NOT IN ('ready', 'pending')")
  scope :shipped, where(:state => ['closed', 'closed_late'])
  scope :not_shipped, where('spree_line_items.state NOT IN (?, ?)', 'closed', 'closed_late')
  scope :closed_on_time, where(:state => 'closed')
  scope :order_by_store, order('store_id')
  scope :by_variant, lambda {|variant_id| where(:variant_id => variant_id)}
  scope :sort_by_order_completed_at_desc, joins(:order).order('spree_orders.completed_at DESC')
  scope :on_sale, where(:on_sale => true)
  scope :not_on_sale, where(:on_sale => false)
  
  class << self # dynamic named scopes
    def distinct_by_store(store_id=nil)
      return if store_id == nil
      items = Spree::LineItem.where(:store_id => store_id).select('DISTINCT spree_line_items.order_id, spree_line_items.id').map {|item| item.id}
      where({:id => items})
    end
  end
   
  # state machine (see http://github.com/pluginaweek/state_machine for details)
  state_machine :initial => :pending, :use_transactions => false do
    event :ready do
      transition :pending => :open
    end
    event :ship do
      transition :open => :closed, :if => :all_units_shipped_on_time?
      transition [:open, :past_due] => :closed_late, :if => :all_units_shipped?
    end
    event :reopen do
      transition :closed => :open, :closed_late => :past_due
    end
    event :late do
      transition :open => :past_due
    end
    event :cancel do
      transition all => :canceled, :if => :allow_cancel?
    end
    event :force_cancel do
      transition all => :canceled
    end
    event :soft_cancel do
      transition [:open, :past_due, :closed, :closed_late] => :canceled, :if => :all_inventory_units_canceled?
      transition :open => :closed, :if => :all_units_shipped_on_time?
      transition [:open, :past_due] => :closed_late, :if => :all_units_shipped?
    end
    event :resume do
      transition :to => :resumed, :from => :canceled, :if => :allow_resume?
    end
    #after_transition :to => :canceled, :do => :after_cancel

  end

  def allow_cancel?
    return false unless order.completed? 
    %w{ready open past_due}.include?(self.state)
  end

  def allow_resume?
    # TODO better define when a vendor can reopen a line item
    true
  end
  
  def all_inventory_units_canceled?
    #puts "inventory units #{self.inventory_units}"
    #puts "self is #{self.inspect}"
    self.inventory_units.not_canceled.all
    #puts "inventory_units not canceled #{self.inventory_units.not_canceled.count} #{self.inventory_units.not_canceled.all}"
    self.inventory_units.not_canceled.count == 0
  end
  
  def all_units_shipped_on_time?
    self.inventory_units.not_canceled.each do |inventory_unit|
      return false if !inventory_unit.shipped? or inventory_unit.shipment.shipped_at - self.order.completed_at >= 2.days
    end
    true
  end
  
  def all_units_shipped?
    self.inventory_units.not_shipped.not_canceled.count == 0
  end
  
  # Determines the appropriate +state+ according to the following logic:
  # pending    unless +order.payment_state+ is +paid+
  def determine_state(order)
    # uncomment to prevent seperate shipment of backorders
    #return "pending" if self.inventory_units.any? {|unit| unit.backordered?}
    return "canceled" if state == "canceled"
    return "closed" if state == "closed"
    return "closed_late" if state == "closed_late"
    return "pending" if order.payment_state == "balance_due"
    return "past_due" if order.payment_state == "paid" and updated_at < DateTime.now - Spree::Config[:shipment_late].to_i.days 
    return "open" if order.payment_state == "paid"
    state
  end

  def copy_price
    if variant and pending?
      self.price = variant.uniform_price
      self.on_sale = variant.sale?
    end
    #self.price = variant.price if variant and (self.price.nil? or self.pending?)
    true
  end
  
  def on_sale?
    self.on_sale
  end
  
  def free_shipping_credits
    line_item_promotion_credits.collect {|lipc| lipc if lipc.promotion_credit.source.calculator.is_a?(Spree::Calculator::FreeShipping)}.delete_if {|lipc| lipc.nil?}
  end
  
  def non_free_shipping_credits
    line_item_promotion_credits.collect {|lipc| lipc if !lipc.promotion_credit.source.calculator.is_a?(Spree::Calculator::FreeShipping)}.delete_if {|lipc| lipc.nil?}
  end
  
  def quantity_available(option=nil)
    quantity - if option == :free_shipping or option.is_a?(Spree::Calculator::FreeShipping)
      puts "   free_shipping_credits #{free_shipping_credits.inspect}"
      free_shipping_credits.sum(&:quantity)
    elsif option == :promotion or (option.is_a?(Spree::Calculator) and option.calculable.is_a?(Spree::Promotion))
      puts "   non_free_shipping_credits #{non_free_shipping_credits.inspect}"
      non_free_shipping_credits.sum(&:quantity)
    else
      0
    end
  end
  
  
  def update!(order)
    update_attribute_without_callbacks "state", determine_state(order)
  end
  
  def calculate!
    calculate_total_amount!
    calculate_commission_percentage!
    calculate_store_amount!
    self.save
  end
  
  def orders_store
    self.order.orders_stores.find_by_store_id(self.store)
  end
  
  def uniform_price
    self.price
  end
  
  #def inventory_units
  #  self.order.inventory_units.find_by_order_id_and_variant_id(self.order, self.variant)
  #end
  
  def commission_percentage_locked?
    self.commission_percentage_lock
  end
  
  private
  
  def update_inventory
    #puts "LineItem#update_inventory called and has been overridden"
  end
  
  #def after_cancel
  #  order.inventory_units.decrease(self.order, self.variant, self.quantity) if !order.inventory_units.blank? # restock_inventory
  #  order.cancel! if order.all_items_canceled? # email sent from order model
  #end
  
  def calculate_total_amount!
    self.total_amount = self.quantity * self.price
  end
  
  def calculate_commission_percentage!
    if !self.commission_percentage_locked? and self.variant #self.pending? or (self.open? and self.variant)
      if self.variant
        self.commission_percentage = (self.variant.commission_percentage || 0) * (self.store.store_tier.nil? ? 1 : (self.store.store_tier.discount / 100))
      end
    end
  end
  
  def calculate_store_amount!
    self.store_amount = ((100 - self.commission_percentage) / 100) * self.total_amount
  end

end