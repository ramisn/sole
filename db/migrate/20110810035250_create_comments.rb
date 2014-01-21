class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :commenter, :polymorphic => true, :null => false
      t.references :feed_item, :null => false
      t.text :message
      
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
