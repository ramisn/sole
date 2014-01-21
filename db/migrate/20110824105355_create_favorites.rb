class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.references :product, :null => false
      t.references :user, :null => false
      
      t.timestamps
    end
    
    add_index :favorites, :user_id
    add_index :favorites, :product_id
    add_index :favorites, [:user_id, :product_id], :unique => true
  end

  def self.down
    drop_table :favorites
  end
end
