class AddAccessTokenToUserAuthentications < ActiveRecord::Migration
  def self.up
    change_table :user_authentications do |t|
      t.string :access_token
    end
  end

  def self.down
    change_table :user_authentications do |t|
      t.remove :access_token
    end
  end
end
