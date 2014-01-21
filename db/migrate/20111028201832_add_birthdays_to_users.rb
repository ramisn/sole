class AddBirthdaysToUsers < ActiveRecord::Migration
  def self.up
	User.all.each do |user|
		if (user.birthday.nil?)
			puts "*** found a user without a birthday: #{user.email}"
			user.birthday = (DateTime.now - 20.year)
			user.save
		end
	end
  end

  def self.down
  end
end
