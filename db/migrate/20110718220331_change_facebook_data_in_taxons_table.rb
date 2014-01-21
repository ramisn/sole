class ChangeFacebookDataInTaxonsTable < ActiveRecord::Migration
  def self.up
    change_table :taxons do |t|
      t.remove :facebook_nickname
      t.string :facebook_name
      t.string :facebook_link
    end
    
    rename_column :taxons_users, :facebook_access_code, :facebook_access_token
  end

  def self.down
    change_table :taxons do |t|
      t.string :facebook_nickname
      t.remove :facebook_name
      t.remove :facebook_link
    end
    
    rename_column :taxons_users, :facebook_access_token, :facebook_access_code
  end
end
