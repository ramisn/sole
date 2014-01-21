class AddUserNames < ActiveRecord::Migration
  def self.up
	usernames = Hash.new
	User.all.each do |user|
		if user.username.nil? && !user.email.blank?
			puts "**** user #{user.email} does not have a username"
			if user.email.blank?
				username = "empty"
			else
				at_sym = user.email.index("@")
				at_sym = user.email.length if at_sym.nil?
				username = user.email[0,[at_sym, 15].min]
			end

			username.sub!(/soletron/i, 'nortelos')
			if username.length < 3
				username = username + "---"
			end
			while username.index("_")
				username.sub!("_", "-")
			end
			while username.index(".")
				username.sub!(".", "-")
			end
			if username.blank?
				username = "empty"
			end
			user.username = username
			user.birthday = DateTime.now - 21.year
			puts "*** assigned him username #{user.username}"
			i = 0
			while true
				puts "*** trying with #{user.username} for #{user.email}"
				if user.save
					puts "*** saved successfully with #{user.username}"
					break
				else
					puts "*** user errors #{user.errors}"
				end
				username = user.email[0,[at_sym, 12].min] + i.to_s
				if username.length < 3
					username = username + "---"
				end				
				while username.index("_")
					username.sub!("_", "-")
				end				
				while username.index(".")
					username.sub!(".", "-")
				end
				user.username = username
				i = i + 1
			end
		end
	end
  end

  def self.down
  end
end
