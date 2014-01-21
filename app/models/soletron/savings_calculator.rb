module Soletron
  class SavingsCalculator

    def self.compute(order, stores = nil)
      stores = [stores || order.stores].flatten
      stores.map { |s| compute_for_store(order, s) }.sum
    end

    protected

    def self.compute_for_store(order, store)
      orders_stores = order.orders_stores.where(store_id: store.id)
      price_difference = orders_stores.map { |os|
        os.line_items.select(&:on_sale?).map { |li|
          (li.product.price * li.quantity) - li.price
        }
      }.flatten.sum
    end
  end
end
