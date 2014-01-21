class AddCommissionColumnsToLineItems < ActiveRecord::Migration
  def self.up
    change_table :line_items do |t|
      t.decimal :total_amount, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal :commission_percentage, :precision => 5, :scale => 2, :default => 0.0, :null => false
      t.decimal :store_amount, :precision => 8, :scale => 2, :default => 0.0, :null => false
    end
  end

  def self.down
    change_table :line_items do |t|
      t.remove :total_amount
      t.remove :commission_percentage
      t.remove :store_amount
    end
  end
end
