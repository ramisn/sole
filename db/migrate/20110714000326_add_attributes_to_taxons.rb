class AddAttributesToTaxons < ActiveRecord::Migration
  def self.up
    change_table :taxons do |t|
      t.integer :year_founded
      t.string :email
      t.string :location
      t.text :company_overview
      t.text :about
      t.text :mission
      t.text :product_types
      t.text :team_members
    end
  end

  def self.down
    change_table :taxons do |t|
      t.remove :year_founded
      t.remove :email
      t.remove :location
      t.remove :company_overview
      t.remove :about
      t.remove :mission
      t.remove :product_types
      t.remove :team_members
    end
  end
end
