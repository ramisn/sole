class AddTypeAndUserToProducts < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
      t.references :user
      t.string :type
    end
  end

  def self.down
    change_table :products do |t|
      t.remove :user_id
      t.remove :type
    end
  end
end
