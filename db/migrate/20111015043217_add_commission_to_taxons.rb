class AddCommissionToTaxons < ActiveRecord::Migration
  def self.up
    change_table :taxons do |t|
      t.decimal :commission_rate, :precision => 5, :scale => 2
    end
  end

  def self.down
    change_table :taxons do |t|
      t.remove :commission_rate
    end
  end
end
