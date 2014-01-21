class FillInConfirmedDateForUsers < ActiveRecord::Migration
  def self.up
	User.all.each do |user|
		if user.confirmed_at.nil?
			if (user.birthday.nil?)
				user.birthday = (DateTime.now - 20.year)
			end
			user.confirmed_at = (DateTime.now - 1.year)
			user.save
		end
	end
  end

  def self.down
  end
end
