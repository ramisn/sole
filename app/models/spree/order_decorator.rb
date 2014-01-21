require 'post_to_facebook'

Spree::Order.class_eval do
  include PostToFacebook
  
  has_many :feedbacks
  has_one :feed_item, :as => :feedable
  
  accepts_nested_attributes_for :user
  
  attr_accessible :use_bill_address
  
  has_many :orders_stores
  
  scope :credit_owed, where(:payment_state => 'credit_owed')
  scope :shipped, where(:shipment_state => ['shipped', 'shipped_late'])
  scope :need_to_ship, where(:shipment_state => [:ready, :past_due])
  scope :past_due, where(:shipment_state => :past_due)
  
  ###
  # Now registering to calculate orders_stores on updates
  ###
  #register_update_hook :calculate_orders_stores
  
  
  state_machine do
    event :force_cancel do
      transition :to => 'canceled'
    end    
  end

  def cc_payment_method
    self.available_payment_methods.detect { |pm| pm.is_a?(Spree::Gateway::AuthorizeNet) || pm.is_a?(Spree::Gateway::Bogus) }
  end
  
  def promotion_credits
    adjustments.promotions
  end
  
  # for the comments controller
  def feed_items
    self.feed_item
  end

  def ip_address
    if request.nil?
      ip = "192.168.1.500"
    else
      ip = request.env['HTTP_X_FORWARDED_FOR']
      if ip.blank?
        ip = request.remote_ip
      end
    end
    ip
  end

  class << self # dynamic named scopes
    def by_store(store_id=nil)
      return if store_id == nil
      orders = Spree::LineItem.distinct_by_store(store_id).map {|item| item.order_id}
      where({:id => orders})
    end
  end
  
  def stores
    stores = line_items.select('DISTINCT spree_line_items.store_id').map {|store| store.store_id}
    Store.where(:id => stores)
  end
  
  def shipping_total
    adjustments.shipping.map(&:amount).sum
  end
  
  def free_shipping_coupon_total
    Spree::Promotion.find_by_sql(
      ActiveRecord::Base.send(
        :sanitize_sql_array, 
        ["select spree_adjustments.* from spree_adjustments, spree_calculators where spree_adjustments.adjustable_id=? AND spree_adjustments.adjustable_type=? AND spree_adjustments.source_type=? AND spree_adjustments.source_id=spree_calculators.calculable_id AND spree_adjustments.source_type=spree_calculators.calculable_type AND spree_calculators.type=?",
          self.id, 'Spree::Order', 'Promotion', 'Spree::Calculator::FreeShipping'])).map(&:amount).sum
  end
  
  def not_free_shipping_promotions
    Spree::Promotion.find_by_sql(
      ActiveRecord::Base.send(
        :sanitize_sql_array, 
        ["select spree_adjustments.* from spree_adjustments, spree_calculators where spree_adjustments.adjustable_id=? AND spree_adjustments.adjustable_type=? AND spree_adjustments.source_type=? AND spree_adjustments.source_id=spree_calculators.calculable_id AND spree_adjustments.source_type=spree_calculators.calculable_type AND spree_calculators.type!=?",
          self.id, 'Spree::Order', 'Promotion', 'Spree::Calculator::FreeShipping']))
  end
  
  def not_free_shipping_nor_lipc_promotions
    not_free_shipping_promotions.collect { |credit| credit if credit.line_item_promotion_credits.count == 0 }.delete_if { |credit| credit.nil? }
  end

  
  def allow_cancel?
    return false unless completed? and state != 'canceled'
    %w{canceled ready backorder pending}.include?(shipment_state) and self.all_items_canceled?
  end
  
  # overriding, because mailers are being called from the controllers instead of this model
  def after_cancel
    
  end
  
  #Supercede to update store_id field
  def add_variant(variant, quantity = 1)
    current_item = contains?(variant)
    if current_item
      current_item.quantity = maximum_quantity(current_item.quantity + quantity)
      current_item.save
    else
      current_item = Spree::LineItem.new(:quantity => maximum_quantity(quantity))
      current_item.variant = variant
      current_item.price   = variant.price
      current_item.store_id = variant.store_id
      self.line_items << current_item
      self.save
    end

    # populate line_items attributes for additional_fields entries
    # that have populate => [:line_item]
    Spree::Variant.additional_fields.select{|f| !f[:populate].nil? && f[:populate].include?(:line_item) }.each do |field|
      value = ""

      if field[:only].nil? || field[:only].include?(:variant)
        value = variant.send(field[:name].gsub(" ", "_").downcase)
      elsif field[:only].include?(:product)
        value = variant.product.send(field[:name].gsub(" ", "_").downcase)
      end
      current_item.update_attribute(field[:name].gsub(" ", "_").downcase, value)
    end

    current_item
  end
  
  def maximum_quantity(qty)
    if qty > 5
      qty = 5
      flash[:notice] = 'Orders are limited to a maximum of 5 of each item.'
    end
    qty
  end
  
  def ship_total
    Soletron::ShipmentCalculator.compute(self)
  end
  # Supercede to include store_id
  # Creates a new shipment (adjustment is created by shipment model)
  def create_shipment!
    line_items.each do |item|
      if (shipment_by_store = Spree::Shipment.by_order(self.id).by_store(item.store_id).first).blank?
        self.shipments << Spree::Shipment.create(:order => self,
                                        :shipping_method_id => Spree::Config[:default_shipping_method_id],
                                        :address => self.ship_address,
                                        :store => item.store,
                                        :state => 'pending')     
      end
    end
  end

  def update_shipment_state
    # clean out empty shipments

    # I am not sure what the purpose of the code below was, but it was aborting the order process...
    # ...since it removed shipments with existing inventory items?
    # `inventory_units.count > 0` should be `inventory_units.count == 0` ??
    # -- Arron

    #empty_shipments = shipments.to_a.reject {|s| s.inventory_units.count > 0}
    #Shipment.delete_all(:id => empty_shipments)
    #shipments.reload
    
    # update state
    self.shipment_state =
    case shipments.count
    when 0
      nil
    when shipments.shipped.count
      if orders_stores.closed_late.count > 0
        "shipped_late"
      else
        "shipped"
      end
    when shipments.ready.count
      "ready"
    when shipments.pending.count
      "pending"
    else
      if orders_stores.canceled.count == orders_stores.count
        "canceled"
      elsif inventory_units.not_canceled.count == inventory_units.shipped.count
        if orders_stores.closed_late.count > 0
          "shipped_late"
        else
          "shipped"
        end
      elsif orders_stores.past_due.count > 0 or orders_stores.closed_late.count > 0
        "partial_late"
      else
        "partial"
      end
    end
    self.shipment_state = "backorder" if backordered?

    if old_shipment_state = self.changed_attributes["shipment_state"]
      self.state_events.create({
        :previous_state => old_shipment_state,
        :next_state     => self.shipment_state,
        :name           => "shipment" ,
        :user_id        => (Spree::User.respond_to?(:current) && Spree::User.current && Spree::User.current.id) || self.user_id
      })
    end
  end
  
  # Supercede to update line_item state
  # This is a multi-purpose method for processing logic related to changes in the Order.  It is meant to be called from
  # various observers so that the Order is aware of changes that affect totals and other values stored in the Order.
  # This method should never do anything to the Order that results in a save call on the object (otherwise you will end
  # up in an infinite recursion as the associations try to save and then in turn try to call +update!+ again.)
  def update!
    puts "Spree::Order#update!"
    line_items.each { |item| item.copy_price }
    
    update_totals
    update_payment_state
    
    # give each of the shipments a chance to update themselves
    shipments.each { |shipment| shipment.update!(self) }#(&:update!)
    update_shipment_state
    # update_adjustments #TODO commented out to make checkout update work
    # update totals a second time in case updated adjustments have an effect on the total

    update_totals

    update_attributes_without_callbacks({
      :payment_state => payment_state,
      :shipment_state => shipment_state,
      :item_total => item_total,
      :adjustment_total => adjustment_total,
      :payment_total => payment_total,
      :total => total
    })

    #ensure checkout payment always matches order total
    if payment and payment.checkout? and payment.amount != total
      payment.update_attributes_without_callbacks(:amount => total)
    end

    line_items.each { |item| item.update!(self) }
    
    @currently_updating = false
    
    update_hooks.each { |hook| self.send hook }
  end

  #
  # had to override it so that process_automatic_promotion is called even after it's finalized, because
  # update_adjustments no longer updates the coupons
  #
  def update_totals(force_adjustment_recalculation=false)
    #puts "order#update_totals"
    self.payment_total = payments.completed.map(&:amount).sum
    self.item_total = line_items.map(&:amount).sum

    process_automatic_promotions

    if force_adjustment_recalculation
      applicable_adjustments, adjustments_to_destroy = adjustments.partition{|a| a.applicable?}
      self.adjustments = applicable_adjustments
      adjustments_to_destroy.each(&:delete)
    end
    
    self.adjustments.reload
    self.adjustment_total = self.adjustments.map(&:amount).sum
    self.total            = self.item_total   + self.adjustment_total
  end

  # Indicates the number of items in the order for a particular store
  def item_count_by_store(store_id)
    line_items.by_store(store_id).map(&:quantity).sum
  end
  
  def subtotal_by_store(store_id)
    line_items.by_store(store_id).not_canceled.to_a.sum { |i| i.amount }
  end
  
  def store_count
    line_items.select('DISTINCT spree_line_items.store_id').length
  end
  
  def self.merchant_status(store_id, order)
    order.line_items.by_store(store_id).each do |item|
      case item.state
        when 'cancelled'
          item_status = 'cancelled'
        when 'past_due'
          item_status = 'past_due'
        when 'closed_late'
          item_status = 'closed_late'
      end
    end
    item_status || 'open'
  end
  
  def finalized?
    !completed_at.nil?
  end

  # Supercede for use_bill_address
  def clone_billing_address
    return unless use_bill_address 
    if bill_address and self.ship_address.nil?
      self.ship_address = bill_address.clone
    else
      self.ship_address.attributes = bill_address.attributes.except("id", "updated_at", "created_at")
    end
    true
  end
  
  def commission_total
    self.orders_stores.sum(:total_amount) - self.orders_stores.sum(:total_reimbursement)
  end
  
  def coupon_total
    # 3.1Break
    # self.promotion_credits.sum(:amount)
    0
  end
  
  def total_quantity
    self.line_items.sum(:quantity)
  end
  
  def all_items_canceled?
    self.line_items.not_canceled.count == 0
  end
  
  ###
  # For posting to Facebook
  ###
  
  def facebook_access_token(options={})
    if self.user.facebook_auth
      self.user.facebook_auth.access_token
    end
  end
  
  def facebook_poster_id(options={})
    if self.user.facebook_auth
      self.user.facebook_auth.uid
    end
  end
  
  def facebook_product_to_name(options={})
    @facebook_product_to_name = self.line_items.limit(1).includes(:product).first.product
  end
  
  def facebook_name(options={})
    facebook_product_to_name(options).name
  end

  def facebook_message(options={})
    more_message = if self.line_items.count == 2
      " and 1 more item"
    elsif self.line_items.count > 3
      " and #{self.line_items.count - 1} more items"
    else
      ""
    end
    
    "#{self.user.name} just purchased #{facebook_product_to_name(options).name}#{more_message} on Soletron"
  end
  
  def facebook_link(options={})
    # This should be changed to the person purchased products later
    facebook_domain_posted_from+product_path(facebook_product_to_name(options))
  end
  
  def facebook_picture_to_use(options={})
    facebook_product_to_name(options).images.empty? ? facebook_domain_posted_from+"/assets/noimage/product.jpg" : facebook_product_to_name(options).images.first.attachment.url(:product)
  end
  
  def facebook_description(options={})
    facebook_product_to_name(options).description
  end
  
  # Commissioning and Admin
  
  def ensure_orders_store(store)
    found = false
    self.orders_stores.each do |orders_store|
      if store == orders_store.store
        found = true
      end
    end
    if !found
      self.orders_stores.create(:store => store)
    end
  end
  
  #def create_orders_stores
  #  self.stores.each do |store|
  #    self.orders_stores.create(:store => store)
  #  end
  #end
  
  def ensure_all_orders_stores
    # Find stores that aren't found in line items
    self.orders_stores.where("orders_stores.store_id NOT IN (?)", self.stores).each do |orders_store|
      self.orders_stores.delete(orders_store)
    end
    
    # find stores that currently have orders_stores
    current_stores = self.orders_stores.includes(:store).collect {|orders_store| orders_store.store}
    
    # build list of stores to have OrdersStores created for
    store_select = Store.where(:id => self.stores)
    if current_stores and current_stores.size > 0
      # do not return stores with existing OrdersStores
      store_select = store_select.where("id NOT IN (?)", current_stores)
    end
    store_select.each do |store|
      self.orders_stores.create(:store => store)
    end
  end
  
  def check_to_remove_orders_store(store)
    if Spree::LineItem.where(:order_id => self, :store_id => store).size == 0
      OrdersStore.delete_all(:order_id => self.id, :store_id => store.id)
      #self.orders_stores.delete(self.orders_stores.find_by_store_id(store))
    end
  end
  
  def calculate_orders_stores
    #ensure_all_orders_stores
    self.orders_stores.each { |orders_store| orders_store.calculate! }
  end
  
  def lock_line_item_commission_percentages
    self.line_items.each {|line_item| line_item.update_attribute_without_callbacks 'commission_percentage_lock', true}
  end
  
  def open_orders_stores
    self.orders_stores.each {|orders_store| if orders_store.inactive? then orders_store.ready! end }
  end
  
  def total_product_reimbursement
    orders_stores.sum(:product_reimbursement) + orders_stores.sum(:store_coupons)
  end
  
  def soletron_commission_base
    item_total + coupon_total
  end
  
  def soletron_commission
    soletron_commission_base - total_product_reimbursement
  end
  
  def soletron_commission_rate
    # needs to include coupons
    soletron_commission / soletron_commission_base * 100.0
  end
  
  #
  # Soletron edit - will not update promotion credits, because we only want process_automatic_promotions
  # to deal with it
  #
  # Updates each of the Order adjustments.  This is intended to be called from an Observer so that the Order can
  # respond to external changes to LineItem, Shipment, other Adjustments, etc.  Adjustments that are no longer
  # applicable will be removed from the association and destroyed.
  def update_adjustments
    # separate into adjustments to keep and adjustements to toss
    obsolete_adjustments = adjustments.not_promotions.select{|adjustment| !adjustment.applicable?}
    obsolete_adjustments.each(&:delete)
    
    # We do not want this to process promotion credits because promotion credits are done in a specific order
    self.adjustments.not_promotions.reload.each(&:update!)
  end
  
  def process_coupon_code
    #puts "removed order#process_coupon_code"
    # this is no longer used so that coupon codes can be used in their precedence in
    # process_automatic_promotions
    return true
  end

  def process_automatic_promotions
    puts "Order#process_automatic_promotions"
    # not reloading promotion credits causes problems when a new promotion credit
    # is created, because the promotion credit is not set within the order yet
    # so they need to be reloaded or else more than one promotion credit will
    # be created for the coupon
    self.promotion_credits.reload
    
    puts "\n\n"

    # destroy all current line item promotion credits because they will be re-created and
    # they are the basis for deciding if a coupon has been used against a line item
    # quantity yet
    self.line_items.each do |line_item|
      puts "line_item #{line_item.inspect}"
      LineItemPromotionCredit.delete_all(:line_item_id => line_item.id)
      #line_item.line_item_promotion_credits.delete_all
      #deleted = line_item.line_item_promotion_credits.delete_all
      #LineItemPromotionCredit.connection.execute("DELETE FROM line_item_promotion_credits WHERE #{ActiveRecord::Base.send :sanitize_sql_for_conditions, ["id=%s", line_item.line_item_promotion_credits]}")
      puts "  lipcs are 1: #{line_item.line_item_promotion_credits.inspect}"
      line_item.line_item_promotion_credits.reload
      puts "  lipcs are 2: #{line_item.line_item_promotion_credits.inspect}"
    end

    promotions, remaining_promotion_credits = build_current_promotions

    puts "promotions: #{promotions.inspect}"

    promotions.each do |promotion|
      puts " is eligible? #{promotion.eligible?(self)}"
      next if !promotion.eligible?(self)
      
      promotion.activate(order: self, coupon_code: promotion.code)
      #puts " amount is #{amount.inspect}"
      #puts " line_item_promotion_credits is #{line_item_promotion_credits.inspect}"
      #promotion_credit = update_promotion_credit(promotion, amount, remaining_promotion_credits.delete(promotion.id))
      #puts " promotion credit is #{promotion_credit.inspect}"

      #update_line_item_promotion_credits(promotion_credit, line_item_promotion_credits) if promotion_credit and line_item_promotion_credits and line_item_promotion_credits.size > 0
      #puts "promotion credit #{promotion_credit.inspect}"
    end
    self.promotion_credits.reload
    
    puts "credits 2: #{self.promotion_credits.inspect}"
    
    # destroy unused promotion credits
    remaining_promotion_credits.each do |key, promotion_credit|
      puts "destroying #{promotion_credit.inspect}"
      promotion_credit.delete
    end
    
    puts "credits 3: #{self.promotion_credits.inspect}"
  end

  # Send each vendor a notice of the completed order.
  def notify_stores_of_order
    self.line_items.select("DISTINCT spree_line_items.store_id").each do |item|
      email = ""
      item.store.managers.each do |manager|
        email += (manager.user.email + ",") unless (manager.nil? || manager.user.nil?)
      end
      Spree::OrderMailer.confirm_sale(self, self.line_items.by_store(item.store_id), email, item.store).deliver if !email.blank?
    end
  end


  private

  #
  # This needs to call Promotion.order_by_precedence in order to ensure that all promotions are in the right
  # precedence order
  #
  def build_current_promotions
    puts "Order#build_current_promotions"
    # setup the current promotion credits for reference
    current_promotion_credits = {}
    current_promotions = []
    self.promotion_credits.each do |promo_credit|
      current_promotion_credits[promo_credit.source.id] = promo_credit
      current_promotions << promo_credit.source
    end
    
    puts "  current promotions is #{current_promotions.inspect}"

    # if the order is finalized, no more promotions can be added to it
    promotions = if finalized?
      puts "  order is finalized"
      current_promotions
    else
      puts "  order not finalized"
      coupon = if @coupon_code
        Spree::Promotion.first(:conditions => ["UPPER(code) = ?", @coupon_code.upcase])
      end
      puts "  eligible_automatic_promotions #{eligible_automatic_promotions.inspect}"
      puts "  coupon #{coupon.inspect}"
      ((current_promotions - [coupon]) + (eligible_automatic_promotions - current_promotions - [coupon]) + [coupon]).delete_if {|item| item.nil? }
    end

    return Spree::Promotion.order_by_precedence(promotions), current_promotion_credits
  end

  def update_promotion_credit(promotion, amount, promotion_credit=nil)

    if promotion_credit
      promotion_credit.update_attributes_without_callbacks(amount: amount, updated_at: Time.now.utc)
      #puts "promo credit: #{promo_credit.inspect}"
      #promo_credit.valid?
      #puts "  errors: #{promo_credit.errors}"
    else
      # need to create a new promotion credit if amount is not 0
      if amount != 0
        #puts "creating new promotion"
        promotion_credit = self.promotion_credits.create(
          :source => promotion,
          :amount => amount,
          :label  => promotion.name
        )
      end
    end

    #puts "promo_credit: #{promo_credit.inspect}"

    promotion_credit
  end

  def update_line_item_promotion_credits(promotion_credit, line_item_promotion_credits)
    ###
    # Save the LineItemPromotionCredits
    ###
    line_item_promotion_credits.collect do |lipc|
      lipc.promotion_credit = promotion_credit
      lipc.save
      lipc.line_item.line_item_promotion_credits.reload
      lipc
    end
  end
  
  def eligible_automatic_promotions
    @eligible_automatic_coupons ||= Spree::Promotion.automatic.select{|c| c.eligible?(self)}
  end
  
  public

  class << self
    
    def update_shipment_states
      Spree::LineItem.not_shipped.not_canceled.joins(:order).where("spree_orders.completed_at <= ?", Time.now - Spree::Config[:shipment_late].to_i.days).update_all(['spree_line_items.state = ?', 'past_due'])
      OrdersStore.open.joins(:order).where("spree_orders.completed_at <= ?", Time.now - Spree::Config[:shipment_late].to_i.days).update_all(['orders_stores.state = ?', 'past_due'])
      Spree::Order.need_to_ship.where("spree_orders.completed_at <= ?", Time.now - Spree::Config[:shipment_late].to_i.days).update_all(:shipment_state => :past_due)
    end
    
  end
end
