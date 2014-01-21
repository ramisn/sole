class Spree::Calculator::FlexiRate < Spree::Calculator
  preference :first_item,      :decimal, :default => 0
  preference :additional_item, :decimal, :default => 0
  preference :max_items,       :decimal, :default => 0

  def self.description
    I18n.t("flexible_rate")
  end

  def self.available?(object)
    true
  end

  def self.register
    super
    ShippingMethod.register_calculator(self)
  end

  # modified so that it uses line_items_for_computer
  def compute(object)
    sum = 0
    max = self.preferred_max_items
    unless object.nil? || line_items_for_compute(object).empty?
      items_count = line_items_for_compute(object).map(&:quantity).sum
      items_count.times do |i|
        if i == 0
          sum += self.preferred_first_item
        elsif (max == 0) or (max >= (i + 1))
          sum += self.preferred_additional_item
        end
      end
    end
    return(sum)
  end
end
