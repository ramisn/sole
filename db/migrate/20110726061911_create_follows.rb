class CreateFollows < ActiveRecord::Migration
  def self.up
    create_table :follows do |t|
      t.references :follower, :polymorphic => true, :null => false
      t.references :following, :polymorphic => true, :null => false
      t.string :state, :default => 'active'
      
      t.timestamps
    end
    
    add_index :follows, [:follower_type, :follower_id, :state]
    add_index :follows, [:following_type, :following_id, :state]
  end

  def self.down
    drop_table :follows
  end
end
