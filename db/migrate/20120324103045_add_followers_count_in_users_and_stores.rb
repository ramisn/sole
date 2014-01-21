class AddFollowersCountInUsersAndStores < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.integer :followers_count, :default => 0
    end
    change_table :stores do |t|
      t.integer :followers_count, :default => 0
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :followers_count
    end
    change_table :stores do |t|
      t.remove :followers_count
    end
  end
end
