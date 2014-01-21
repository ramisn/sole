require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# require 'yaml'
# if `ruby --version`.split[1].to_f >= 1.9
#   YAML::ENGINE.yamler= 'syck'
# end
