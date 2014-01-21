class AddLineItemToInventoryUnits < ActiveRecord::Migration
  def self.up
    change_table :inventory_units do |t|
      t.references :line_item
    end
    
    add_index :inventory_units, :line_item_id
  end

  def self.down
    change_table :inventory_units do |t|
      t.remove :line_item_id
    end
  end
end
