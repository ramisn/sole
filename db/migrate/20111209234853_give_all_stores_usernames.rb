class GiveAllStoresUsernames < ActiveRecord::Migration
  def self.up
    Store.all.each do |store|
      if store.username.blank?
        store.set_username
        store.save
      end
    end
  end

  def self.down
  end
end
