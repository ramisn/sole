class CreateConsolidatedFeedItems < ActiveRecord::Migration
  def self.up
    create_table :consolidated_feed_items do |t|
      t.references :feed_item
      t.references :consolidated, :polymorphic => true
      
      t.timestamps
    end
    
    add_index :consolidated_feed_items, :feed_item_id
    add_index :consolidated_feed_items, :consolidated_type
  end

  def self.down
    drop_table :consolidated_feed_items
  end
end
