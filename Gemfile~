source 'http://rubygems.org'

$ruby_version = `ruby --version`.split[1].to_f

gem 'nokogiri', '1.5.5'

gem 'rails', '3.1.4'

gem 'mysql2', '0.3.11'
gem 'sprockets'

group :assets do
  gem 'execjs'
  gem 'therubyracer', :platforms => :ruby
  gem 'sass-rails',   "3.1.4"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier',     ">= 1.0.3"
  gem 'yui-compressor'
  #   gem 'therubyracer', '0.9.9'
  
end

gem 'jquery-rails', '1.0.19'

gem 'activemerchant', :require => 'active_merchant'

#gem 'aws-s3', :require => 'aws/s3' # load aws very early - otherwise interferes with Spree calculators
gem 'aws-sdk'

gem 'deface', '0.7.2'

#gem 'omniauth'

gem 'dynamic_form' # spree forms had used error_messages_on, and this is now housed in dynamic_form
gem 'composite_primary_keys' # for the stores_users table because it doesn't have an id column
gem 'fgraph' # for facebook graph api querying
gem 'koala' # for facebook graph api querying
gem 'sitemap_generator'
gem 'capistrano', '2.9.0'
gem 'capistrano-ext', '1.2.1'
gem 'daemons'
gem 'delayed_job_active_record'
gem 'newrelic_rpm'

gem 'json'
gem 'json_pure'
gem 'prawn', '1.0.0.rc1'
gem 'prawn-layout'
gem 'prawn-core'
gem 'prawn-security'

#gem 'multi_json', '~> 1.3'

# Always load spree gems last (other than dev and test gems)
gem 'highline', '1.6.8'

gem 'spree', '1.0.4'
gem 'spree_social', :git => "git://github.com/spree/spree_social.git", :branch => '1-0-stable'
gem 'spree_paypal_express', :git => "git://github.com/spree/spree_paypal_express.git", :branch => '1-0-stable'
gem 'spree_gateway', :git => 'git://github.com/spree/spree_gateway.git', :branch => "1-0-stable"

gem 'validates_timeliness'
gem 'exceptional'
gem 'sitemap_generator'

gem 'kaminari'

gem 'sunspot_rails'
# gem 'spree_sunspot_search', :git => 'git@github.com:jbrien/spree_sunspot_search.git'
# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'


group :production, :staging do
	gem 'god', '~> 0.12.1'
  gem 'thin'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:

group :development do
  gem 'ruby-prof'
  gem 'sqlite3', '1.3.5'
  gem 'taps', '0.3.23'
  gem 'rvm-capistrano'
  gem 'rails-dev-tweaks', '~> 0.6.1'
end

group :development, :test do
  gem 'active_reload'
  gem 'ya2yaml'
  gem 'rspec-rails'
  gem 'faker'
  gem 'pry-rails'
  #gem 'ruby-debug19'
  #   gem 'webrat'
  #gem 'ruby-debug-base19', "0.11.24"
  #gem 'ruby-debug19', "0.11.6"
  gem 'sunspot_solr'
end

group :test do
  gem 'rspec-rails'
  # cucumber-rails in 1.2 gets rid of tableish, so features with that will need to be converted on upgrade.
  gem 'cucumber-rails', "~> 1.1.0" 
  gem 'factory_girl', "~> 3.4"
  gem 'factory_girl_rails', "~> 3.4"
  gem 'autotest'
  gem 'autotest-inotify'
  gem 'database_cleaner'
  gem 'pickle'
  gem 'email_spec'
  gem 'capybara', "~> 1.1.0"
  gem 'capybara-mechanize', "~> 0.3.0.rc3"
  gem 'launchy'
  gem 'shoulda'
  gem 'faker'
  gem 'jasmine'
end

group :cucumber do
  gem 'capybara', "~> 1.1.0"
  gem 'capybara-mechanize', "~> 0.3.0.rc3"
  gem 'database_cleaner'
  gem 'cucumber-rails', "~> 1.1.0" 
  gem 'rspec-rails'
  gem 'spork'
  gem 'launchy'    # So you can do Then show me the pag
  gem 'jasmine'
  gem 'database_cleaner'
end  
