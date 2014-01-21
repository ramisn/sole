class CreateFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :feedbacks do |t|
      t.references :order, :null => :false
      t.references :store, :null => :false
      
      t.text :message
      t.decimal :rating, :precision => 2, :scale => 1
      t.string :state, :default => 'needed', :null => false
      t.datetime :feedback_left_at
      
      t.timestamps
    end
    
    add_index :feedbacks, :order_id
    add_index :feedbacks, :store_id
    add_index :feedbacks, [:order_id, :store_id], :unique => true
    
    change_table :stores do |t|
      t.decimal :feedback_rating, :precision => 2, :scale => 1
    end
  end

  def self.down
    drop_table :feedbacks
    change_table :stores do |t|
      t.remove :feedback_rating
    end
  end
end
