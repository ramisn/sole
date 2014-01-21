class PromotionChangesToSubclassOfActivator < ActiveRecord::Migration
  include ActiveRecord::ConnectionAdapters::Quoting
  
  def up
    #drop_table :promotions
    
    change_table :spree_activators do |t|
      t.integer :store_id
      t.integer :product_id
      t.datetime :deleted_at
    end
    add_index :spree_activators, :store_id
    add_index :spree_activators, :product_id
    
    rename_column :spree_promotion_rules, :promotion_id, :activator_id
    add_index :spree_promotion_rules, :activator_id
  end

  def down
    #create_table :promotions, :force => true do |t|
    #  t.string   :name
    #  t.string   :code
    #  t.string   :description
    #  t.integer  :usage_limit
    #  t.boolean  :combine
    #  t.datetime :expires_at
    #  t.datetime :starts_at
    #  t.string   :match_policy, :default => 'all'
    #
    #  t.timestamps
    #end
    
    change_table :spree_activators do |t|
      t.remove :store_id
      t.remove :product_id
      t.remove :deleted_at
    end
    rename_column :promotion_rules, :activator_id, :promotion_id
  end
end
