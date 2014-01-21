# A rule to limit a promotion to a specific user.
class Spree::Promotion::Rules::StoreTotal < Spree::PromotionRule

  preference :amount, :decimal, :default => 100.00
  preference :operator, :string, :default => '>'

  OPERATORS = ['gt', 'gte']

  def eligible?(order)
    orders_store = order.orders_stores.find_by_store_id(self.promotion.store)
    orders_store.product_sales.send(preferred_operator == 'gte' ? :>= : :>, preferred_amount) if self.promotion.store and orders_store
  end
end
