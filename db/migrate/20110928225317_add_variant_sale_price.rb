class AddVariantSalePrice < ActiveRecord::Migration
  def self.up
	add_column :variants, :sale_price, :decimal, :null => true, :default => nil, :precision => 8, :scale => 2
  end

  def self.down
	remove_column :variants, :sale_price
  end
end
