class MakeStoreUsernamesUnique < ActiveRecord::Migration
  def self.up
    add_index :stores, :username, :unique => true
  end

  def self.down
    remove_index :stores, :username
  end
end
