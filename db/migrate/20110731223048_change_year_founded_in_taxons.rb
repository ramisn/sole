class ChangeYearFoundedInTaxons < ActiveRecord::Migration
  def self.up
    rename_column :taxons, :year_founded, :founded
    change_column :taxons, :founded, :string
  end

  def self.down
    change_column :taxons, :founded, :integer
    rename_column :taxons, :founded, :year_founded
  end
end
