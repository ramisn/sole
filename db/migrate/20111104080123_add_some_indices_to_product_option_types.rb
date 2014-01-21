class AddSomeIndicesToProductOptionTypes < ActiveRecord::Migration
  def self.up
    add_index :product_option_types, [:product_id, :option_type_id], :unique => true
  end

  def self.down
    remove_index :product_option_types, :column => [:product_id, :option_type_id]
  end
end