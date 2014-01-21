class AddFeaturedToImages < ActiveRecord::Migration
  def self.up
	add_column :assets, :featured, :boolean, :default => false, :null => false
  end

  def self.down
	remove_column :assets, :featured
  end
end
