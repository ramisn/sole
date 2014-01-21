class UpdateExistingFollowers < ActiveRecord::Migration
  def self.up
    @stores = Store.all
    @stores_followers = Follow.followers_count(@stores)
    @stores.each do|store|
      store.update_attribute("followers_count",@stores_followers[[store.class.name, store.id]].to_i)
    end

    @members = User.viewable
    @members_followers = Follow.followers_count(@members)
    @members.each do|member|
      member.update_attribute("followers_count",@members_followers[[member.class.name, member.id]].to_i)
    end
  end

  def self.down
  end
end
