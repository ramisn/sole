class AddUsernameToUsersAndStores < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :username
    end
    add_index :users, :username, :unique => true
    
    change_table :taxons do |t|
      t.string :username
    end
    add_index :taxons, :username, :unique => true
  end

  def self.down
    change_table :users do |t|
      t.remove :username
    end
    
    change_table :taxons do |t|
      t.remove :username
    end
  end
end
