
set :deploy_to, "/home/shopdev/rails_apps/SoletronDev"

set :branch, "master"



after "deploy", "deploy:restartThin"
namespace :deploy do
	
		task :restartThin do
				#run "cd /home/shopdev/rails_apps/SoletronDev; git pull origin staging"
				run "cd /home/shopdev/rails_apps/SoletronDev; bundle install"
				run "cd /home/shopdev/rails_apps/SoletronDev; RAILS_ENV=production rake db:migrate"
				run "cd /home/shopdev/rails_apps/SoletronDev; RAILS_ENV=production SERVER=shop thin -d -e production -p 12002 --servers 10 stop"
				run "cd /home/shopdev/rails_apps/SoletronDev; RAILS_ENV=production SERVER=shop thin -d -e production -p 12002 --servers 10 start"
		end

	
end


