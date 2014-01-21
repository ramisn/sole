# From - http://media.pragprog.com/titles/fr_rr/code/CreateFixturesFromLiveData/lib/tasks/extract_fixtures.rake

desc 'Create YAML test fixtures from data in an existing database.  
Defaults to development database.  Set RAILS_ENV to override.'

task :extract_fixtures => :environment do
  
  def make_fixtures(table_name)
    sql  = "SELECT * FROM %s"
    i = "000"
    File.open("#{Rails.root}/test/fixtures/#{table_name}.yml", 'w') do |file|
      data = ActiveRecord::Base.connection.select_all(sql % table_name)
      file.write data.inject({}) { |hash, record|
        hash["#{table_name}_#{i.succ!}"] = record
        hash
      }.to_yaml
    end
  end
  
  ActiveRecord::Base.establish_connection
  
  if ENV.has_key?('table')
    make_fixtures(ENV['table'])
  else
    skip_tables = ["schema_info"]
    (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name|
      make_fixtures(table_name)
    end
  end
end


###
# Not ready yet
###
task :run_tests_once => 'db:test:prepare' do
  #begin
  #  require 'cucumber'
  #  require 'cucumber/rake/task'
  #  require 'rspec/core'
  #  require 'rspec/core/rake_task'
  #rescue LoadError => e
  #  puts "problem loading test tasks"
  #  puts e
  #end
  #
  #Cucumber::Rake::Task.new
  #RSpec::Core::RakeTask.new(:my_spec) do |spec|
  #  spec.pattern = "./spec/**/*_spec.rb"
  #end
  Rake::Task["cucumber:all"].reenable
  Rake::Task["cucumber:all"].invoke
  Rake::Task["spec"].reenable
  Rake::Task["spec"].invoke
end

