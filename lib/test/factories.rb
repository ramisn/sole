####
# The factories contained are modified versions of those in Spree v0.70.0
####

Spree::Zone.class_eval do
  def self.global
    find_by_name("GlobalZone") || FactoryGirl.create(:global_zone)
  end
end

require 'factory_girl'
# FactoryGirl.definition_file_paths = %w(lib/test/factories)
# FactoryGirl.find_definitions
#Dir["#{File.dirname(__FILE__)}/factories/**"].each do |f|
#  fp =  File.expand_path(f)
#  require fp
#end