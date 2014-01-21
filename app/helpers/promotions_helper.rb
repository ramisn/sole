module PromotionsHelper
  
  def promotion_discount(promotion)
    if promotion.calculator.is_a?(Spree::Calculator::FlexiRate)
      "First: #{promotion.calculator.preferred_first_item}, Other Items: #{promotion.calculator.preferred_additional_item}, Max: #{promotion.calculator.preferred_max_items}"
    elsif promotion.calculator.is_a?(Spree::Calculator::FlexiPercent)
      "First: #{promotion.calculator.preferred_first_item}%, Other Items: #{promotion.calculator.preferred_additional_item}%, Max: #{promotion.calculator.preferred_max_items}"
    elsif promotion.calculator.is_a?(Spree::Calculator::FlatPercentItemTotal)
      "#{promotion.calculator.preferred_flat_percent}%"
    elsif promotion.calculator.is_a?(Calculator::BuyXGetYAtZPercentOff)
      "Buy #{promotion.calculator.preferred_buy_number_of_items_x} Get #{promotion.calculator.preferred_get_number_of_items_y} at #{promotion.calculator.preferred_at_z_percent_off}% Off"
    elsif promotion.calculator.is_a?(Calculator::FreeItem)
      "Get a Free Item"
    end
  end
  
end
