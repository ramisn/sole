class AddMoreProfileDataToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.date :birthday
      t.string :gender
      t.text :favorite_bands
      t.text :favorite_sneakers
      t.text :favorite_street_shops
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :birthday
      t.remove :gender
      t.remove :favorite_bands
      t.remove :favorite_sneakers
      t.remove :favorite_street_shops
    end
  end
end
