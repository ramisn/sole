class Spree::Calculator::FlatPercent < Spree::Calculator
  preference :flat_percent_off, :decimal, :default => 0

  def self.description
    I18n.t("flat_percent")
  end

  def self.available?(object)
    true
  end
  
  def compute(object)
    return 0, [] unless object.present? and self.preferred_flat_percent_off.present?
    save_value = lambda do |calculator, line_item|
      #puts "price #{line_item.price} @ #{calculator.preferred_flat_percent_off} off"
      calculator.preferred_flat_percent_off / 100.0 * line_item.price
    end
    
    compute_line_items(object, save_value, linked_object: LineItemPromotionCredit)
  end
  
end
