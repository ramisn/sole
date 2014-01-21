# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Soletronspree::Application.initialize!

ACTIONS = {:previous => "action.previous", :preview => "action.preview", :next => "action.next"}
STATUS = {:new => "status.new", :default => "", :edit => "status.edit", :delete => "status.delete"}
DEPT_TAXONS = {:newly_added => "Newly Added", :featured => "Featured", :custom => "Custom Products", :on_sale => "On Sale"}