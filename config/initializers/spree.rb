# These are custom preferences
class Spree::AppConfiguration
  preference :title_max_characters, :integer, :default => 22
  preference :title_sale_max_characters, :integer, :default => 12
  preference :store_max_characters, :integer, :default => 22
  preference :default_product_groups, :string, :default =>   'All,Featured,On Sale'
  preference :shipment_late, :integer, :default =>   2  # Number of days before an order is considered late if not shipped
  preference :default_shipping_method_id, :integer, :default =>   574015644 
  preference :second_shipment_method_id, :integer, :default =>   574015644 # the shipping method to use when a vendor splits a shipment
  preference :auto_rotate_msec, :integer, :default =>   3000 # how often images are to be rotated
  preference :newly_added_period_days, :integer, :default =>   30  # how long products remain marked as newly added
  preference :show_price_inc_vat, :boolean, :default => false

  def temp_set(attrs = {}, &block)
    prev = {}
    attrs.keys.each { |key| prev[key] = Spree::Config[key] }
    Spree::Config.set(attrs)
    result = yield
    Spree::Config.set(prev)
    result
  end
end

Spree.config do |config|
  config.site_name                          =  'Soletron'
  config.logo                               =  '/assets/logo.png'
  config.admin_interface_logo               =  '/assets/logo.png'
  config.products_per_page                  =  48
  config.auto_capture                       =  true 
  config.shipping_instructions              =  true
  config.allow_guest_checkout               =  true
  config.track_inventory_levels             =  true
  config.create_inventory_units             =  true
  config.show_zero_stock_products           =  true
  config.allow_backorders                   =  false
  config.allow_ssl_in_development_and_test  =  false
  config.default_meta_keywords              =  "streetwear = street wear = urban clothing = sneakerhead = sneakerheads = street style = urban wear = urban apparel = urban fashion = Soletron = Santonio Holmes"
  config.default_meta_description           =  "Soletron = owned by Santonio Holmes = is the ideal place to shop for your streetwear = sneakerhead = and urban apparel clothing."
  config.title_max_characters               =  22
  config.title_sale_max_characters          =  12
  config.store_max_characters               =  22
  config.default_product_groups             =  'Featured,On Sale'
  config.shipment_late                      =  2  # Number of days before an order is considered late if not shipped
  config.default_shipping_method_id         =  574015644 
  config.second_shipment_method_id          =  574015644 # the shipping method to use when a vendor splits a shipment
  config.auto_rotate_msec                   =  3000 # how often images are to be rotated
  config.newly_added_period_days            =  30  # how long products remain marked as newly added
  config.show_price_inc_vat                 =  false
end


# Uncomment if you want to use instead of sunspot
# You will also have to disable sunspot
# require "soletron/searcher"


