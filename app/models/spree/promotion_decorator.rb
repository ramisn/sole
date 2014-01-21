Spree::Promotion.class_eval do
  
  # for linking a promotion to a specific product
  belongs_to :product
  
  # for linking a promotion to a specific store
  belongs_to :store
  
  # from Spree 0.60
  scope :automatic, where("code IS NULL OR code = ''")

  default_scope lambda { where(:deleted_at => nil) }
  
  def automatic?
    code.blank? and !expired?
  end
  
  def deleted?
    deleted_at
  end

  # modifying because on a recalculation of a completed order, the promotion should still be eligible on it
  # it looks like this was causing promotion credits to get deleted when an order was updated after the promotion
  # had expired
  def eligible?(order)
    order.completed? or (!expired? and rules_are_eligible?(order))
  end

  def expired?
    (starts_at and Time.now < starts_at) or
      (expires_at and Time.now > expires_at) or
      (usage_limit and credits_count >= usage_limit) or
      deleted?
  end
  
  # for debugging
  def activate(payload)
    puts "Spree::Promotion#activate"
    puts "  created_at condition #{created_at.to_i < payload[:order].created_at.to_i}"
    puts "  unactivatable states condition #{!UNACTIVATABLE_ORDER_STATES.include?(payload[:order].state)}"
    return unless order_activatable? payload[:order]
    puts "  order is activatable"
    if code.present?
      puts "  code is present"
      event_code = payload[:coupon_code].to_s.strip.downcase
      return unless event_code == self.code.to_s.strip.downcase
    end

    if path.present?
      puts "  path is present"
      return unless path == payload[:path]
    end
    
    puts "  performing actions"
    actions.each do |action|
      action.perform(payload)
      puts "    action performed on #{action.inspect}"
    end
    puts "  actions performed"
  end

  def order_activatable?(order)
    order &&
    # Promotion does not have to be created before the order was
    #created_at.to_i < order.created_at.to_i &&
    !UNACTIVATABLE_ORDER_STATES.include?(order.state)
  end
  
  #def create_discount(order)
  #  return if order.promotion_credit_exists?(self)
  #  amount, line_item_promotion_credits = calculator.compute(order)
  #  if eligible?(order) and amount and amount > 0
  #    amount = order.item_total if amount > order.item_total
  #    order.promotion_credits.reload.clear unless combine? and order.promotion_credits.all? { |credit| credit.source.combine? }
  #
  #    order.update!
  #    
  #    ###
  #    # Moved this here, so that the order doesn't need to be reloaded to get access to the promotion credits
  #    ###
  #    promotion_credit = order.promotion_credits.create!({
  #        :label => "#{I18n.t(:coupon)} (#{code})",
  #        :source => self,
  #        :amount => -amount.abs
  #      })
  #
  #    (line_item_promotion_credits || []).each do |lipc|
  #      lipc.promotion_credit = promotion_credit
  #      lipc.save
  #      lipc.line_item.line_item_promotion_credits.reload
  #    end
  #  end
  #end
  #
  ## simple override, just now allowing for multiple return values
  #def compute(order)
  #  amount, lipcs = calculator.compute(order)
  #  amount = order.item_total if amount > order.item_total
  #  return -amount, lipcs
  #end
  
  class << self
    
    ###
    # Make sure that product promotion take precedence over store promotions
    # and store promotions over site promotions
    ###
    def order_by_precedence(promotions)
      promotions.delete_if {|promo| promo.nil? }.sort_by do |promotion| 
        if promotion.product 
          0
        elsif promotion.store
          1
        else
          2
        end
      end
    end
    
  end
end
