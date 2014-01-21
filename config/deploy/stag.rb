
set :deploy_to, "/home/shopstag/rails_apps/SoletronStage"

set :branch, "staging"



namespace :deploy do
	
	
		#run "cd /home/shopstag/rails_apps/SoletronStage; git pull origin staging"
		#run "cd /home/shopstag/rails_apps/SoletronStage; bundle install"
		#run "cd /home/shopstag/rails_apps/SoletronStage; RAILS_ENV=production rake db:migrate"
		#run "cd /home/shopstag/rails_apps/SoletronStage; RAILS_ENV=production SERVER=shop thin -d -e production -p 12002 --servers 10 stop"
		#run "cd /home/shopstag/rails_apps/SoletronStage; RAILS_ENV=production SERVER=shop thin -d -e production -p 12002 --servers 10 start"
	
end


