# 31Break
# Now Spree::Adjustments
#class Spree::PromotionCredit
#  has_many :line_item_promotion_credits, :dependent => :destroy
#  has_many :line_items, :through => :line_item_promotion_credits
#  
#  # Calculates credit for the coupon.
#  #
#  # If coupon amount exceeds the order item_total, credit is adjusted.
#  #
#  # Always returns negative non positive.
#  def calculate_coupon_credit
#    return 0 if order.line_items.not_on_sale.empty?
#    
#    ###
#    # Send only line items that have not been put on sale to the calculator
#    ###
#    amount = source.calculator.compute(order).abs
#    amount = order.item_total if amount > order.item_total
#    -1 * amount
#  end
#  
#  after_destroy :remove_free_product_if_free_item
#  
#  private
#  
#  def remove_free_product_if_free_item
#    if source.calculator.is_a?(Calculator::FreeItem) and source.product
#      free_line_item = source.calculator.line_items_for_compute(order).first
#      free_line_item.decrement_quantity if free_line_item
#    end
#  end
#  
#  def save_update_order?
#    false
#  end
#end
#