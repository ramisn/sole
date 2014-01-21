class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.references :notifying, :polymorphic => true, :null => false
      t.references :item, :polymorphic => true, :null => false
      t.string :state
      
      t.timestamps
    end
    
    add_index :notifications, [:notifying_type, :notifying_id]
  end

  def self.down
    drop_table :notifications
  end
end
