class AddConfirmationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :confirmed_at, :datetime
    add_index :users, :confirmation_token, :unique => true
    remove_column(:users, :active) if User.column_names.include?('active')
  end

  def self.down
    remove_column :users, :confirmation_token
    remove_column :users, :confirmation_sent_at
    remove_column :users, :confirmed_at
  end
end
