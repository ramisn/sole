class CreateFeedItems < ActiveRecord::Migration
  def self.up
    create_table :feed_items do |t|
      t.references :displayable, :polymorphic => true, :null => false
      t.references :feedable, :polymorphic => true, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_items
  end
end
