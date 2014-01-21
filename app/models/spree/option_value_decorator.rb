Spree::OptionValue.class_eval do
  # Return products linked to the option value.
  def products
    product_ids = self.variants.joins(:product).map(&:product).map(&:id)
    Spree::Product.where("spree_products.id IN (?)", product_ids)
  end
end