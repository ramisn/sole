class MoveFacebookManagerToStores < ActiveRecord::Migration
  def self.up
    change_table :stores do |t|
      t.boolean :facebook_manager
      t.string :facebook_access_token
    end

    change_table :taxons_users do |t|
      t.remove :facebook_manager
      t.remove :facebook_access_token
    end	
  end
  
  def self.down
    change_table :stores do |t|
      t.remove :facebook_manager
      t.remove :facebook_access_token
    end

    change_table :taxons_users do |t|
      t.boolean :facebook_manager
      t.string :facebook_access_token
    end	
  end
end
