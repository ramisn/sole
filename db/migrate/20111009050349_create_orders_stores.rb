class CreateOrdersStores < ActiveRecord::Migration
  def self.up
    create_table :orders_stores do |t|
      t.references :order, :null => false
      t.references :store, :null => false
      t.decimal :product_sales, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal :coupons, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal :shipping, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal :total_amount, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal :store_cut, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.timestamps
    end
    
    add_index :orders_stores, :order_id
    add_index :orders_stores, :store_id
    add_index :orders_stores, [:order_id, :store_id], :unique => true
  end

  def self.down
    drop_table :orders_stores
  end
end
