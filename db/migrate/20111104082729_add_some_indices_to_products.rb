class AddSomeIndicesToProducts < ActiveRecord::Migration
  def self.up
    add_index :products, :product_id
    add_index :products, :brand_id
    add_index :products, :featured_image_id
    add_index :products, :shipping_category_id
    add_index :products, :tax_category_id
  end

  def self.down
    remove_index :products, :tax_category_id
    remove_index :products, :shipping_category_id
    remove_index :products, :featured_image_id
    remove_index :products, :brand_id
    remove_index :products, :product_id
  end
end