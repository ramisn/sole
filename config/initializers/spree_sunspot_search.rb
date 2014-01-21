require 'spree_core'
require 'sunspot_rails'
require 'spree/search/spree_sunspot/configuration'
require 'spree/search/spree_sunspot'

Spree::Search::SpreeSunspot.configure do |conf|
  conf.price_ranges     = []
  conf.option_facets    = [:color1, :sizes]
  conf.property_facets  = [:brand]
  conf.other_facets     = []
  conf.show_facets      = []
  conf.fields           = []
  conf.sort_fields      = {}
end

Spree::Config.searcher_class = Spree::Search::SpreeSunspot::Search