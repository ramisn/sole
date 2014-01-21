class CreateStores < ActiveRecord::Migration
  def self.up
    begin drop_table :stores rescue true end
    
    create_table :stores do |t|
      t.integer :taxon_id
      t.string :name
      t.text :description
      t.string :founded
      t.string :email
      t.string :location
      t.text :company_overview
      t.text :about
      t.text :mission
      t.text :product_types
      t.text :team_members
      t.string :meta_keywords
      t.string :meta_description
      t.string :facebook_id
      t.string :facebook_name
      t.string :facebook_link
      t.string :username
      t.timestamps
    end
    add_index :stores, :taxon_id
    add_index :stores, :name
  end

  def self.down
    drop_table :stores
  end
end
