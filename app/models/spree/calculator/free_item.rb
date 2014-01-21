class Spree::Calculator::FreeItem < Spree::Calculator

  def self.description
    I18n.t("free_item")
  end
  
  def compute(object)
    line_item = line_items_for_compute(object).first
    
    # if the line item doesn't exist, create a new one based-on the master
    if line_item.nil? or line_item.quantity == 0
      object.add_variant calculable.product.master
      calculable.product.master.price
    else
      line_item.price
    end
  end
end
