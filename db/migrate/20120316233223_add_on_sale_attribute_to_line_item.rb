class AddOnSaleAttributeToLineItem < ActiveRecord::Migration
  def self.up
    change_table :line_items do |t|
      t.boolean :on_sale, :default => false, :null => false
    end
  end

  def self.down
    change_table :line_items do |t|
      t.remove :on_sale
    end
  end
end
