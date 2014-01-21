class MakeFollowerFollowingUnique < ActiveRecord::Migration
  def self.up
    add_index :follows, [:follower_type, :follower_id, :following_type, :following_id], :unique => true, :name => "follows_unique_follower_and_following"
  end

  def self.down
    remove_index :follows, :name => "follows_unique_follower_and_following"
  end
end
