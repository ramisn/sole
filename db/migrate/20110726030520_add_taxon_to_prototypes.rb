class AddTaxonToPrototypes < ActiveRecord::Migration
  def self.up
    change_table :prototypes do |t|
      t.integer :taxon_id
    end
  end

  def self.down
    change_table :prototypes do |t|
      t.remove :taxon_id
    end
  end
end