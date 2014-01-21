Spree::Shipment.class_eval do
  belongs_to :store
  
  scope :by_store, lambda {|store_id| where(:store_id => store_id)}
  scope :by_order, lambda {|order_id| where(:order_id => order_id)}
  scope :not_shipped, where("spree_shipments.state <> 'shipped'")
  
  def orders_store
    order.orders_stores.find_by_store_id(store)
  end
  
  def all_inventory_units_canceled?
    #puts "shipment iu's not canceled #{self.inventory_units.not_canceled.all}"
    self.inventory_units.not_canceled.count == 0
  end
  
  state_machine do
    event :cancel do
      transition :from => ['pending', 'ready', 'shipped'], :to => 'canceled', :if => :all_inventory_units_canceled?
    end
    
    event :force_cancel do
      transition :to => 'canceled'
    end
  end
  
  def can_ship2?
    self.can_ship?
  end
  
  def amount
    if adjustment
      adjustment.amount 
    else 
      0
    end
  end
  
  def late?
    ((self.shipped? ? self.shipped_at : Time.now.utc) - self.order.completed_at) >= 2.days
  end
  
  def self.default
    new :shipping_method_id => Spree::Config[:default_shipping_method_id]
  end
  
  def line_items
    if order.complete? and Spree::Config[:track_inventory_levels]
      order.line_items.by_store(self.store).select {|li| inventory_units.map(&:variant_id).include?(li.variant_id)}
    else
      order.line_items.by_store(self.store)
    end
  end
  
  # This rate_hash is used instead of Order#rate_hash, because it allows for getting the cost of each
  # shipping method per store/shipment
  def rate_hash
    @rate_hash ||= self.order.available_shipping_methods(:front_end).collect do |ship_method|
      cost = ship_method.calculator.compute(self)
      next unless cost
      { :id => ship_method.id,
        :shipping_method => ship_method,
        :name => ship_method.name,
        :cost => cost
      }
    end.compact.sort_by{|r| r[:cost]}
  end
  
  # Need to make it so that more than one adjustment is not created for each order.
  def ensure_correct_adjustment
    if adjustment
      adjustment.originator = shipping_method
      adjustment.save
    # make it so that a new adjustment is only made if there are no other shipping adjustments for that store
    elsif order.adjustments.shipping.joins('INNER JOIN spree_shipments ON spree_shipments.id=spree_adjustments.source_id').where('spree_shipments.store_id=?', store_id).count == 0
      shipping_method.create_adjustment(I18n.t(:shipping), order, self, true)
      reload #ensure adjustment is present on later saves
    end
  end  
  
  private
  
  def after_ship
    self.update_attributes_without_callbacks "state" => "shipped", 
                                             "shipped_at" => DateTime.now,
                                             "vendor_shipping_method" => self.vendor_shipping_method,
                                             "tracking" => self.tracking
    inventory_units.each &:ship!
    ShipmentMailer.shipped_email(self).deliver
  end
  
end

