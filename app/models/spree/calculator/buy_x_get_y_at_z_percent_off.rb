class Spree::Calculator::BuyXGetYAtZPercentOff < Spree::Calculator
  preference :buy_number_of_items_x,      :decimal, :default => 0
  preference :get_number_of_items_y,      :decimal, :default => 0
  preference :at_z_percent_off,           :decimal, :default => 0

  def self.description
    I18n.t("buy_x_get_y_at_z_percent_off")
  end

  def self.available?(object)
    true
  end
  
  #
  # This function sets up the functions that are sent to compute_line_items
  # to figure out the value that is calculated and also return the line item promotion credits
  # that will be attached to them as wel
  #
  def compute(object)
    return 0, [] if self.preferred_buy_number_of_items_x.blank? or 
                self.preferred_buy_number_of_items_x == 0 or
                self.preferred_get_number_of_items_y.blank? or 
                self.preferred_get_number_of_items_y == 0 or
                self.preferred_at_z_percent_off.blank? or
                self.preferred_at_z_percent_off == 0
                
    #puts "Buy #{self.preferred_buy_number_of_items_x} Get #{self.preferred_get_number_of_items_y} at #{self.preferred_at_z_percent_off}% Off"
    
    save_test = lambda do |calculator, options={}|
      #puts " save test: #{options[:count] % (self.preferred_buy_number_of_items_x + self.preferred_get_number_of_items_y) >= self.preferred_buy_number_of_items_x}"
      options[:count] % (self.preferred_buy_number_of_items_x + self.preferred_get_number_of_items_y) >= self.preferred_buy_number_of_items_x
    end
    
    save_value = lambda do |calculator, line_item|
      #puts " save value: #{calculator.preferred_at_z_percent_off / 100.0 * line_item.price}"
      calculator.preferred_at_z_percent_off / 100.0 * line_item.price
    end
    
    add_false_items_to_current = lambda do |calculator, line_item|
      true
    end
    
    compute_line_items(object, save_value, linked_object: LineItemPromotionCredit, save_test: save_test, add_false_items_to_current: add_false_items_to_current)
  end
end
