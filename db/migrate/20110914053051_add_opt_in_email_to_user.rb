class AddOptInEmailToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :opt_in_email, :boolean, :default => false, :null => false
    add_index :users, :opt_in_email
  end

  def self.down
    remove_column :users, :opt_in_email
  end
end
