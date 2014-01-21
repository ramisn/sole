class CreateStoresBrands < ActiveRecord::Migration
  def self.up
    create_table :brands_stores, :id => false do |t|
      t.integer :store_id
      t.integer :brand_id
    end
    add_index :brands_stores, :store_id
    add_index :brands_stores, :brand_id
  end

  def self.down
    drop_table :brands_stores
  end
end
