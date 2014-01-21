class CreateBrands < ActiveRecord::Migration
  def self.up
	create_table :brands do |t|
		t.string :name
		t.timestamps
	end
	add_index :brands, :name
	
	add_column :products, :brand_id, :integer
  end

  def self.down
	drop_table :brands
	remove_column :products, :brand_id
  end
end
