Spree::Calculator::PerItem.class_eval do

  def compute(object=nil)
    self.preferred_amount * line_items_for_compute(object).length
  end
  
end

  