Spree::Calculator::FlatPercentItemTotal.class_eval do
  
  def self.description
    I18n.t("flat_percent_item_total")
  end

  #
  # Compute has been modified to use the method line_items_for_compute
  #
  def compute(object)
    computing_line_items = line_items_for_compute(object)
    return unless object.present? and computing_line_items.present?
    
    item_total = computing_line_items.map(&:amount).sum
    value = item_total * self.preferred_flat_percent / 100.0
    return (value * 100).round.to_f / 100, computing_line_items.collect {|line_item| LineItemPromotionCredit.new(line_item: line_item, quantity: line_item.quantity_available(self))}
  end
  
end
