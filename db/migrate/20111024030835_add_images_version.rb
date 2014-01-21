class AddImagesVersion < ActiveRecord::Migration
  def self.up
	add_column :assets, :version, :integer, :default => 0
  end

  def self.down
	remove_column :assets, :version
  end
end
