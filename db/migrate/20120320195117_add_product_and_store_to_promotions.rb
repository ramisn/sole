class AddProductAndStoreToPromotions < ActiveRecord::Migration
  def self.up
    change_table :promotions do |t|
      t.references :store
      t.references :product
    end
  end

  def self.down
    change_table :promotions do |t|
      t.remove :store_id
      t.remove :product_id
    end
  end
end
