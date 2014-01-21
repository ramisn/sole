Spree::InventoryUnit.class_eval do
  
  belongs_to :line_item
  belongs_to :refund
  belongs_to :canceled_by, :class_name => 'Spree::User'
  belongs_to :vendor_payment_reversal, :class_name => 'VendorPayment' # only used if the inventory unit is canceled and a payment reversal happens
  
  scope :not_shipped, where("spree_inventory_units.state != 'shipped'")
  scope :shipped, where(:state => :shipped)
  scope :by_variant, lambda {|variant_id| where(:variant_id => variant_id)}
  scope :sold, where(:state => :sold)
  scope :not_canceled, where('spree_inventory_units.state != ?', 'canceled')
  scope :canceled, where(:state => :canceled)
  
  state_machine do
    event :cancel do
      transition 'sold' => 'canceled'
    end
    
    event :force_cancel do
      transition :to => 'canceled'
    end
  end
  
  def self.create_units(order, variant, sold, back_order)
    puts "\n\nInventoryUnits.create_units FLAGGED and has been overridden\n\n"
    
    if back_order > 0 && !Spree::Config[:allow_backorders]
      raise "Cannot request back orders when backordering is disabled"
    end

    shipment = order.shipments.detect {|shipment| !shipment.shipped? and shipment.store_id == variant.store_id }
    
    line_item = order.line_items.find_by_variant_id(variant)
   
    sold.times { order.inventory_units.create(:variant => variant, :state => "sold", :shipment => shipment, :line_item => line_item) }
    back_order.times { order.inventory_units.create(:variant => variant, :state => "backordered", :shipment => shipment, :line_item => line_item) }
  end
  
  def self.decrease(order, variant, quantity)
    puts "\n\nInventoryUnit.decrease FLAGGED and has been overridden\n\n"
    #if Spree::Config[:track_inventory_levels]
    #   variant.increment!(:count_on_hand, quantity)
    #end
    
    ###
    # Commenting out so that we can retain the inventory units
    ###
    #if Spree::Config[:create_inventory_units]
    #  destroy_units(order, variant, quantity)
    #end
    #line_item = order.line_items.find_by_variant_id(variant)
    #if line_item.pending?
    #  if Spree::Config[:create_inventory_units]
    #    destroy_units(order, variant, quantity)
    #  end
    #else
    #  
    #  #inventory_units = line_item.inventory_unit.not_shipped.not_canceled
    #  #num_to_cancel = inventory_units.count
    #  #if quantity < num_to_cancel
    #  #  num_to_cancel = quantity
    #  #end
    #  #
    #  #quantity.times do |i|
    #  #  inventory_units[i].cancel
    #  #end
    #end
  end  
  
  #def my_line_item
  #  if line_item.nil?
  #    update_attributes(:line_item => self.order.line_items.find_by_variant_id(self.variant))
  #  end
  #  line_item
  #end
  
  #def cancel!
  #  self.order.line_items.each do |item|
  #    if item.variant_id == self.variant.id
  #      if item.quantity == 1
  #        item.cancel!
  #      else
  #        item.decrement_quantity
  #        item.save(:validate => false)
  #        item.variant.increment!(:count_on_hand, 1) if Spree::Config[:track_inventory_levels]
  #      end
  #    end
  #  end
  #end

end