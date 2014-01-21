class AddFacebookManagePageDataToTaxonsAndTaxonsUsers < ActiveRecord::Migration
  def self.up
    change_table :taxons do |t|
      t.string :facebook_id
      t.string :facebook_nickname
    end
    
    change_table :users do |t|
      t.boolean :facebook_manage_pages
    end
    
    change_table :taxons_users do |t|
      t.boolean :facebook_manager
      t.string :facebook_access_code
    end
  end

  def self.down
    change_table :taxons do |t|
      t.remove :facebook_id
      t.remove :facebook_nickname
    end
    
    change_table :users do |t|
      t.remove :facebook_manage_pages
    end
    
    change_table :taxons_users do |t|
      t.remove :facebook_manager
      t.remove :facebook_access_code
    end
  end
end
