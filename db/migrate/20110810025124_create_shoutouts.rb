class CreateShoutouts < ActiveRecord::Migration
  def self.up
    create_table :shoutouts do |t|
      t.references :poster, :polymorphic => true, :null => false
      t.references :posted_to, :polymorphic => true, :null => false
      t.text :content
      
      t.timestamps
    end
  end

  def self.down
    drop_table :shoutouts
  end
end
