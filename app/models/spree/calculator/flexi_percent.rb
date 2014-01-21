class Spree::Calculator::FlexiPercent < Spree::Calculator
  preference :first_item,     :decimal, :default => 0
  preference :additional_item, :decimal, :default => 0
  preference :max_items,       :decimal, :default => 0
  preference :min_items_until_additional_item_amount_kicks_in,       :decimal, :default => 0

  def self.description
    I18n.t("flexible_percent")
  end

  def self.available?(object)
    true
  end
  
  #
  # The highest priced line item get's the first item percentage regardless
  #
  def compute(object)
    puts self.inspect
    puts self.calculable.inspect
    puts self.preferences.inspect
    sum = 0
    max = self.preferred_max_items
    min_exists = self.preferred_min_items_until_additional_item_amount_kicks_in
    min = min_exists || 0
    
    count = 0
    line_items_for_compute(object).order('line_items.price DESC').each do |line_item|
      line_item.quantity.times do |i|
        puts "count: #{count}, max: #{max}, min_exists: #{min_exists}, min: #{min}"
        sum += if (count == 0) or (max > 0 and count % max == 0) or (min_exists and ((max and count % max <= min) or (!max and count <= min)))
          self.preferred_first_item * line_item.price
        else
          self.preferred_additional_item * line_item.price
        end
        
        count += 1
      end
    end
    
    return sum
  end
end
