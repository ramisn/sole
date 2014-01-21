class RenameLocationToCurrentCity < ActiveRecord::Migration
  def self.up
    rename_column :users, :location, :current_city
  end

  def self.down
    rename_column :users, :current_city, :location
  end
end
