set :deploy_to, "/home/shoplive/rails_apps/SoletronLive"

set :branch, "live"

namespace :deploy do
		#run "cd /home/shoplive/rails_apps/SoletronLive; git pull origin live"
		#run "cd /home/shoplive/rails_apps/SoletronLive; bundle install"
		#run "cd /home/shoplive/rails_apps/SoletronLive; RAILS_ENV=production rake db:migrate"
		#run "cd /home/shoplive/rails_apps/SoletronLive; RAILS_ENV=production SERVER=shop thin -d -e production -p 12002 --servers 10 stop"
		#run "cd /home/shoplive/rails_apps/SoletronLive; RAILS_ENV=production SERVER=shop thin -d -e production -p 12002 --servers 10 start"

end


