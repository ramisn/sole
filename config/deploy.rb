#$:.unshift(File.expand_path("./lib", ENV["rvm_path"]))
require "rvm/capistrano"

set :application, "SoletronSpree"
set :repository,  "git@github.com:soletron/SoletronSpree.git"


ssh_options[:compression] = "none"
ssh_options[:forward_agent] = true

set :deploy_via, :remote_cache

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#set :stages, %w(dev stag live)

#set :default_stage, "dev"

#require 'capistrano/ext/multistage'
#require "bundler/capistrano"

#set :branch, "master"

#set :keep_releases, 10

set :user, "root"
set :use_sudo, false
set :job_template, nil
set :rvm_type, :system

role :web, "shop-dev-298.soletron.com"                          # Your HTTP server, Apache/etc
role :app, "shop-dev-298.soletron.com"                          # This may be the same as your `Web` server
role :db,  "shop-dev-298.soletron.com", :primary => true # This is where Rails migrations will run

#after "deploy", "deploy:cleanup"
#after "deploy:finalize_update", "deploy:migrate"

###
# Justin's note - 11/21/2011
# In order to make sure that the staging servers don't use credentials for the shop
# server, like the usa epay stuff, I removed the SERVER=shop to all of those below.
###

namespace :deploy do
  task :dev do
    set :rvm_ruby_string, "ruby-1.9.2-p290@soletron_dev"
    set :deploy_to, "/home/shopdev/rails_apps/SoletronDev"
    run "cd /home/shopdev/rails_apps/SoletronDev; git checkout db/schema.rb"
    
    ###
    # For upgrading
    ###
    #run "cd /home/shopdev/rails_apps/SoletronDev; bundle install"
    #run "cd /home/shopdev/rails_apps/SoletronDev; git fetch origin database_migrations"
    #run "cd /home/shopdev/rails_apps/SoletronDev; git pull origin database_migrations"
    #run "cd /home/shopdev/rails_apps/SoletronDev; git checkout database_migrations"
    #begin
    #  run "cd /home/shopdev/rails_apps/SoletronDev; RAILS_ENV=staging bundle exec rake db:migrate --trace"
    #rescue => e
    #  puts "ERROR"
    #  e.backtrace.each {|error| puts "  #{error}"}
    #end
    #run "cd /home/shopdev/rails_apps/SoletronDev; git checkout db/schema.rb"
    #run "cd /home/shopdev/rails_apps/SoletronDev; git checkout master"
    #run "cd /home/shopdev/rails_apps/SoletronDev; git add ."
    #run "cd /home/shopdev/rails_apps/SoletronDev; git commit -m 'auto-commit via cap:deploy'"
    #run "cd /home/shopdev/rails_apps/SoletronDev; git push origin master"
    run "cd /home/shopdev/rails_apps/SoletronDev; git pull origin master"
    #run "cd /home/shopdev/rails_apps/SoletronDev; gem install pg -v '0.12.0'"
    run "cd /home/shopdev/rails_apps/SoletronDev; bundle install --without test development cucumber"
    run "cd /home/shopdev/rails_apps/SoletronDev; RAILS_ENV=staging SERVER=\"shop-dev-298\" script/delayed_job stop"
    run "cd /home/shopdev/rails_apps/SoletronDev; RAILS_ENV=staging bundle exec rake db:migrate"
    run "cd /home/shopdev/rails_apps/SoletronDev; RAILS_ENV=staging SERVER=\"shop-dev-298\" rake assets:precompile"
    run "cd /home/shopdev/rails_apps/SoletronDev; RAILS_ENV=staging SERVER=\"shop-dev-298\" thin -d -e production -p 12002 --servers 3 stop"
    run "cd /home/shopdev/rails_apps/SoletronDev; RAILS_ENV=staging SERVER=\"shop-dev-298\" thin -d -e production -p 12002 --servers 3 start"
    run "cd /home/shopdev/rails_apps/SoletronDev; RAILS_ENV=staging SERVER=\"shop-dev-298\" rake sunspot:solr:reindex"
    run "cd /home/shopdev/rails_apps/SoletronDev; RAILS_ENV=staging SERVER=\"shop-dev-298\" script/delayed_job start"
  end

  task :stage do
    set :rvm_ruby_string, "ruby-1.9.2-p290@soletron_staging"
    set :deploy_to, "/home/shopstag/rails_apps/SoletronStage"
    run "cd /home/shopstag/rails_apps/SoletronStage; git pull origin staging"
    run "cd /home/shopstag/rails_apps/SoletronStage; bundle install --without test development cucumber"
    run "cd /home/shopstag/rails_apps/SoletronStage; git checkout db/schema.rb"
    run "cd /home/shopstag/rails_apps/SoletronStage; RAILS_ENV=production SERVER=\"shop-stage-298\" script/delayed_job stop"
    run "cd /home/shopstag/rails_apps/SoletronStage; RAILS_ENV=production rake db:migrate"
    run "cd /home/shopstag/rails_apps/SoletronStage; RAILS_ENV=production SERVER=\"shop-dev-298\" rake assets:precompile"
    run "cd /home/shopstag/rails_apps/SoletronStage; RAILS_ENV=production SERVER=\"shop-stage-298\" thin -d -e production -p 12005 --servers 4 stop"
    run "cd /home/shopstag/rails_apps/SoletronStage; RAILS_ENV=production SERVER=\"shop-stage-298\" thin -d -e production -p 12005 --servers 4 start"
    run "cd /home/shopstag/rails_apps/SoletronStage; RAILS_ENV=production SERVER=\"shop-stage-298\" rake sunspot:solr:reindex"
    run "cd /home/shopstag/rails_apps/SoletronStage; RAILS_ENV=production SERVER=\"shop-stage-298\" script/delayed_job start"
    run "bundle exec rake assets:clean && bundle exec rake assets:precompile"
  end

  task :live do
    set :rvm_ruby_string, "ruby-1.9.2-p290@soletron_live"
    set :deploy_to, "/home/shoplive/rails_apps/SoletronLive"
    run "cd /home/shoplive/rails_apps/SoletronLive; git pull origin live"
    run "cd /home/shoplive/rails_apps/SoletronLive; bundle install --without test development cucumber"
    run "cd /home/shoplive/rails_apps/SoletronLive; git checkout db/schema.rb"
    run "cd /home/shoplive/rails_apps/SoletronLive; RAILS_ENV=production SERVER=\"shop-live-298\" script/delayed_job stop"
    run "cd /home/shoplive/rails_apps/SoletronLive; RAILS_ENV=production rake db:migrate"
    run "cd /home/shoplive/rails_apps/SoletronLive; RAILS_ENV=production SERVER=\"shop-live-298\" rake assets:precompile"
    run "cd /home/shoplive/rails_apps/SoletronLive; RAILS_ENV=production SERVER=\"shop-live-298\" thin -d -e production -p 12009 --servers 3 stop"
    run "cd /home/shoplive/rails_apps/SoletronLive; RAILS_ENV=production SERVER=\"shop-live-298\" thin -d -e production -p 12009 --servers 3 start"
    run "cd /home/shoplive/rails_apps/SoletronLive; RAILS_ENV=production SERVER=\"shop-live-298\" rake sunspot:solr:reindex"
    run "cd /home/shoplive/rails_apps/SoletronLive; RAILS_ENV=production SERVER=\"shop-live-298\" script/delayed_job start"
  end


# desc "Start the Thin processes"
#  task :start do
#    sudo "bundle exec thin -d -e production -p 12002 --servers 10 start -C thin.yml"
#  end
#
#  desc "Stop the Thin processes"
#  task :stop do
#    sudo "bundle exec thin -d -e production -p 12002 --servers 10 stop -C thin.yml"
#  end
#
#  desc "Restart the Thin processes"
#  task :restart do
#    sudo "bundle exec thin restart -C thin.yml"
#  end
     
end




