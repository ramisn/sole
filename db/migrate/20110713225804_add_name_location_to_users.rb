class AddNameLocationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :location, :string
    add_column :users, :name, :string
  end

  def self.down
    remove_column :users, :name
    remove_column :users, :location
  end
end
