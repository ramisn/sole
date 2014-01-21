class DropTaxonUsersTable < ActiveRecord::Migration
  def self.up
	drop_table :taxons_users
  end

  def self.down
    create_table :taxons_users, :id => false do |t|
      t.column :taxon_id, :integer
      t.column :user_id, :integer
    end
  end
end
