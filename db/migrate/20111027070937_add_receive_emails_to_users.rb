class AddReceiveEmailsToUsers < ActiveRecord::Migration
  def self.up
	add_column :users, :receive_emails, :integer, :default => 0
  end

  def self.down
	remove_column :users, :receive_emails
  end
end
