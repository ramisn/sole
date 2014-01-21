class CreateTaxonsUsersTable < ActiveRecord::Migration
  def self.up
    create_table :taxons_users, :id => false do |t|
      t.column :taxon_id, :integer
      t.column :user_id, :integer
    end
  end

  def self.down
    drop_table :taxons_users
  end
end
