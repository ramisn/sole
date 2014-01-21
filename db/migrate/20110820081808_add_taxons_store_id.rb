class AddTaxonsStoreId < ActiveRecord::Migration
  def self.up
	add_column :taxons, :store_id, :integer
	remove_column :stores, :taxon_id
  end

  def self.down
	add_column :stores, :taxon_id, :integer
	remove_column :taxons, :store_id  
  end
end
