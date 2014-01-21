Spree::Promotion::Actions::CreateAdjustment.class_eval do

  def perform(options = {})
    puts "Spree::Promotion::Actions::CreateAdjustment#perform"
    return unless order = options[:order]
    # Nothing to do if the promotion is already associated with the order
    puts "  order sent"
    puts "  promotion_credit_exists? #{order.promotion_credit_exists?(promotion)}"
    if order.promotion_credit_exists?(promotion)
      update_adjustment(order)
    else
      puts "  promotion credit not already attached"
  
      order.adjustments.promotion.reload.clear
      puts "  promotion reloaded"
      #order.update!
      #puts "  order updated"
      create_adjustment("#{I18n.t(:promotion)} (#{promotion.name})", order, order)
      puts "  adjustment created"
    end
  end
  
  def update_adjustment(order)
    puts "Spree::Promotion::Actions::CreateAdjustment#create_adjustment"
    amount, lipcs = compute_amount(order)
    
    puts "  promotion computed"
    puts "  amount is #{amount.inspect}"
    puts "  lipcs is #{lipcs.inspect}"
    
    credit = order.adjustments.promotion.reload.detect { |credit| credit.originator.promotion.id == promotion.id }
    puts "  credit found"
    credit.update_attribute_without_callbacks 'amount', amount
    puts "  credit amount updated"

    (lipcs || []).each do |lipc|
      lipc.promotion_credit = credit
      lipc.save
      puts "  saved lipc"
      lipc.line_item.line_item_promotion_credits.reload
      puts "  reloaded lipc"
    end
    
    credit
  end
  
  # override of CalculatedAdjustments#create_adjustment so promotional
  # adjustments are added all the time. They will get their eligability
  # set to false if the amount is 0
  def create_adjustment(label, target, calculable, mandatory=false)
    puts "Spree::Promotion::Actions::CreateAdjustment#create_adjustment"
    amount, lipcs = compute_amount(calculable)
    
    puts "  amount is #{amount.inspect}"
    puts "  lipcs is #{lipcs.inspect}"
    #order.promotion_credits.reload.clear unless combine? and order.promotion_credits.all? { |credit| credit.source.combine? }

    #order.update!
    
    ###
    # Moved this here, so that the order doesn't need to be reloaded to get access to the promotion credits
    ###
    credit = target.adjustments.create({
      :amount => amount,
      :source => promotion,# was calculable, but calculable was order and need to use source
      :originator => self,
      :label => label,
      :mandatory => mandatory
    }, :without_protection => true)
    
    #promotion_credit = order.promotion_credits.create!({
    #    :label => "#{I18n.t(:coupon)} (#{code})",
    #    :source => self,
    #    :amount => -amount.abs
    #  })

    (lipcs || []).each do |lipc|
      lipc.promotion_credit = credit
      lipc.save
      lipc.line_item.line_item_promotion_credits.reload
    end
    
    credit
  end

  # Ensure a negative amount which does not exceed the sum of the order's item_total and ship_total
  def compute_amount(calculable)
    amount, lipcs = super
    amount = amount.to_f.abs
    return [(calculable.item_total + calculable.ship_total), amount.to_f.abs].min * -1, lipcs
  end  
  
  def create_discount(order)
    puts "Spree::Promotion::Actions::CreateAdjustment#create_discount"
    return if order.promotion_credit_exists?(self)
    #amount, lipcs = compute_amount(calculable)
    
    amount, line_item_promotion_credits = calculator.compute(order)
    puts "  amount is #{amount.inspect}"
    puts "  lipcs is #{lipcs.inspect}"
    if eligible?(order) and amount and amount > 0
      puts "  order is eligible and not amount of 0"
      amount = order.item_total if amount > order.item_total
      order.promotion_credits.reload.clear unless combine? and order.promotion_credits.all? { |credit| credit.source.combine? }

      order.update!
      
      ###
      # Moved this here, so that the order doesn't need to be reloaded to get access to the promotion credits
      ###
      promotion_credit = order.promotion_credits.create!({
          :label => "#{I18n.t(:coupon)} (#{code})",
          :source => self,
          :amount => -amount.abs
        })
      puts "  promotion credit is #{promotion_credit.inspect}"
      (line_item_promotion_credits || []).each do |lipc|
        lipc.promotion_credit = promotion_credit
        lipc.save
        lipc.line_item.line_item_promotion_credits.reload
      end
      puts "  line item promotion credits #{line_item_promotion_credits.inspect}"
    end
  end
  
  # simple override, just now allowing for multiple return values
  def compute(order)
    amount, lipcs = calculator.compute(order)
    amount = order.item_total if amount > order.item_total
    return -amount, lipcs
  end

end
