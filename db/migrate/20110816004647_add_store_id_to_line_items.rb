class AddStoreIdToLineItems < ActiveRecord::Migration
  def self.up
    add_column :line_items, :store_id, :integer
    add_index :line_items, :store_id
  end

  def self.down
    remove_column :line_items, :store_id
    remove_index :line_items, :store_id
  end
end
