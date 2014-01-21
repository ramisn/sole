class AddCanceledAtAndCanceledByToOrderRelatedModels < ActiveRecord::Migration
  def self.up
    change_table :inventory_units do |t|
      t.datetime :canceled_at
      t.integer :canceled_by
    end
    add_index :inventory_units, :canceled_at
    add_index :inventory_units, :canceled_by
    
    change_table :line_items do |t|
      t.datetime :canceled_at
      t.integer :canceled_by
    end
    add_index :line_items, :canceled_at
    add_index :line_items, :canceled_by
    
    change_table :orders_stores do |t|
      t.datetime :canceled_at
      t.integer :canceled_by
    end
    add_index :orders_stores, :canceled_at
    add_index :orders_stores, :canceled_by
    
    change_table :orders do |t|
      t.datetime :canceled_at
      t.integer :canceled_by
    end
    add_index :orders, :canceled_at
    add_index :orders, :canceled_by
    
    change_table :shipments do |t|
      t.datetime :canceled_at
      t.integer :canceled_by
    end
    add_index :shipments, :canceled_at
    add_index :shipments, :canceled_by
  end

  def self.down
    change_table :inventory_units do |t|
      t.remove :canceled_at
      t.remove :canceled_by
    end
    
    change_table :line_items do |t|
      t.remove :canceled_at
      t.remove :canceled_by
    end
    
    change_table :orders_stores do |t|
      t.remove :canceled_at
      t.remove :canceled_by
    end
    
    change_table :orders do |t|
      t.remove :canceled_at
      t.remove :canceled_by
    end
    
    change_table :shipments do |t|
      t.remove :canceled_at
      t.remove :canceled_by
    end
  end
end
