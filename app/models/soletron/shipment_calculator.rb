module Soletron
  class ShipmentCalculator
    def self.compute(order, stores = nil)
      stores = [stores || order.stores].flatten
      stores.map { |s| compute_for_store(order, s) }.sum
    end

    protected

    # Calculates shipping for a store.
    # This is hard-coded: It's $3.99 per store
    # plus $1.00 per item.
    def self.compute_for_store(order, store)
      orders_stores = order.orders_stores.where(store_id: store.id)
      item_count = orders_stores.map { |os| os.line_items.map(&:quantity) }.flatten.sum
      3.99 + (item_count * 1.00)
    end
  end
end
