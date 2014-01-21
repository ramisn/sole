class FollowJob < Struct.new(:follow_id)
  
  def perform
    follow = Follow.find(follow_id)
    case follow.following
    when Spree::User
      FollowMailer.user_followed(follow).deliver
    when Store
      store = follow.following
      store.users.each do |manager|
        FollowMailer.delay.store_followed(follow, manager)
      end
    end
  end
  
end
