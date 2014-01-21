class LineItemPromotionCredit < ActiveRecord::Base
  belongs_to :line_item, :class_name => "Spree::LineItem"
  belongs_to :promotion_credit, :class_name => 'Spree::Adjustment'

  def store_amount
    #puts "line item #{line_item.inspect}"
    #puts " amount #{amount * ((100 - line_item.commission_percentage) / 100.0)}"
    #puts " amount: #{amount}"
    #puts " commission_percentage: #{line_item.commission_percentage}"
    amount * ((100 - line_item.commission_percentage) / 100.0)
  end
end
