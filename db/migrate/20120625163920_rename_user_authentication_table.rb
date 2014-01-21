class RenameUserAuthenticationTable < ActiveRecord::Migration
  def change
    rename_table :user_authentications,     :spree_user_authentications
  end
end
