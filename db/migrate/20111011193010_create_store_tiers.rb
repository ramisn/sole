class CreateStoreTiers < ActiveRecord::Migration
  def self.up
    create_table :store_tiers do |t|
      t.string :name, :null => false
      t.decimal :discount, :precision => 5, :scale => 2, :default => 0.0, :null => false
      
      t.timestamps
    end
    
    
    change_table :stores do |t|
      t.references :store_tier
    end
    add_index :stores, :store_tier_id
  end

  def self.down
    drop_table :store_tiers
  end
end
