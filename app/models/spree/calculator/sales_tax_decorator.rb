#Spree::Calculator::SalesTax.class_eval do
#
#  def compute(order)
#    # bringing back this until the taxes are database driven
#    return 0 if !order.ship_address or !order.ship_address.state or !(order.ship_address.state.name == 'Florida' and order.ship_address.state.country.iso == 'US')
#    
#    # calculate the total for products at this rate
#    product_total = 0
#    rate = self.calculable
#    line_items = order.line_items.select { |i| i.variant and i.variant.product and i.variant.product.tax_category == rate.tax_category }
#    product_total = line_items.inject(0) do |sum, line_item|
#      sum += line_item.total
#    end
#    
#    ###
#    # The total amount won't be calculated until after this, so the following are calculated here
#    ###
#    
#    # calculate the total of the line items
#    order_product_total = order.line_items.map(&:total).sum
#    
#    if order_product_total != 0
#      # calculate the total of the coupons
#      coupon_total = order.promotion_credits.sum(:amount)
#      
#      # this applies the coupon amount relative to the amount that the products here are part of the order total
#      # then rounds it and converts it to a number with two decimal points
#      coupon_amount = ((((product_total / order_product_total) * coupon_total) + 0.005) * 100).to_i / 100.0
#      
#      # return the amount of tax, coupon is a negative amount
#      rate.amount * (product_total + coupon_amount)
#    else
#      0
#    end
#  end
#end