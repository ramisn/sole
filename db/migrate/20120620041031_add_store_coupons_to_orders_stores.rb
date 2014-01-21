class AddStoreCouponsToOrdersStores < ActiveRecord::Migration
  def self.up
    change_table :orders_stores do |t|
      t.decimal :store_coupons, :precision => 8, :scale => 2, :default => 0.0
    end
  end

  def self.down
    change_table :orders_stores do |t|
      t.remove :store_coupons
    end
  end
end
