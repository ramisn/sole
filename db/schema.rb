# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120912000000) do

  create_table "authentication_methods", :force => true do |t|
    t.string   "environment"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brands", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "brands", ["name"], :name => "index_brands_on_name"

  create_table "brands_stores", :id => false, :force => true do |t|
    t.integer "store_id"
    t.integer "brand_id"
  end

  add_index "brands_stores", ["brand_id"], :name => "index_brands_stores_on_brand_id"
  add_index "brands_stores", ["store_id"], :name => "index_brands_stores_on_store_id"

  create_table "comments", :force => true do |t|
    t.integer  "commenter_id",   :null => false
    t.string   "commenter_type", :null => false
    t.integer  "feed_item_id",   :null => false
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "consolidated_feed_items", :force => true do |t|
    t.integer  "feed_item_id"
    t.integer  "consolidated_id"
    t.string   "consolidated_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "consolidated_feed_items", ["consolidated_type"], :name => "index_consolidated_feed_items_on_consolidated_type"
  add_index "consolidated_feed_items", ["feed_item_id"], :name => "index_consolidated_feed_items_on_feed_item_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "favorites", :force => true do |t|
    t.integer  "product_id", :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["product_id"], :name => "index_favorites_on_product_id"
  add_index "favorites", ["user_id", "product_id"], :name => "index_favorites_on_user_id_and_product_id", :unique => true
  add_index "favorites", ["user_id"], :name => "index_favorites_on_user_id"

  create_table "feed_items", :force => true do |t|
    t.integer  "displayable_id",   :null => false
    t.string   "displayable_type", :null => false
    t.integer  "feedable_id",      :null => false
    t.string   "feedable_type",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "initiator_id"
    t.string   "initiator_type"
  end

  create_table "feedbacks", :force => true do |t|
    t.integer  "order_id"
    t.integer  "store_id"
    t.text     "message"
    t.decimal  "rating",           :precision => 2, :scale => 1
    t.string   "state",                                          :default => "needed", :null => false
    t.datetime "feedback_left_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feedbacks", ["order_id", "store_id"], :name => "index_feedbacks_on_order_id_and_store_id", :unique => true
  add_index "feedbacks", ["order_id"], :name => "index_feedbacks_on_order_id"
  add_index "feedbacks", ["store_id"], :name => "index_feedbacks_on_store_id"

  create_table "follows", :force => true do |t|
    t.integer  "follower_id",                          :null => false
    t.string   "follower_type",                        :null => false
    t.integer  "following_id",                         :null => false
    t.string   "following_type",                       :null => false
    t.string   "state",          :default => "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "line_item_promotion_credits", :force => true do |t|
    t.integer  "line_item_id"
    t.integer  "promotion_credit_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount",              :precision => 8, :scale => 2, :default => 0.0, :null => false
  end

  add_index "line_item_promotion_credits", ["line_item_id"], :name => "index_line_item_promotion_credits_on_line_item_id"
  add_index "line_item_promotion_credits", ["promotion_credit_id"], :name => "index_line_item_promotion_credits_on_promotion_credit_id"

  create_table "notifications", :force => true do |t|
    t.integer  "notifying_id",   :null => false
    t.string   "notifying_type", :null => false
    t.integer  "item_id",        :null => false
    t.string   "item_type",      :null => false
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["notifying_type", "notifying_id"], :name => "index_notifications_on_notifying_type_and_notifying_id"

  create_table "orders_stores", :force => true do |t|
    t.integer  "order_id",                                                                       :null => false
    t.integer  "store_id",                                                                       :null => false
    t.decimal  "product_sales",            :precision => 8, :scale => 2, :default => 0.0,        :null => false
    t.decimal  "coupons",                  :precision => 8, :scale => 2, :default => 0.0,        :null => false
    t.decimal  "shipping",                 :precision => 8, :scale => 2, :default => 0.0,        :null => false
    t.decimal  "total_amount",             :precision => 8, :scale => 2, :default => 0.0,        :null => false
    t.decimal  "product_reimbursement",    :precision => 8, :scale => 2, :default => 0.0,        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "total_reimbursement",      :precision => 8, :scale => 2, :default => 0.0,        :null => false
    t.string   "state",                                                  :default => "inactive", :null => false
    t.datetime "completed_at"
    t.integer  "vendor_payment_period_id"
    t.datetime "canceled_at"
    t.integer  "canceled_by"
    t.decimal  "store_coupons",            :precision => 8, :scale => 2, :default => 0.0
  end

  add_index "orders_stores", ["canceled_at"], :name => "index_orders_stores_on_canceled_at"
  add_index "orders_stores", ["canceled_by"], :name => "index_orders_stores_on_canceled_by"
  add_index "orders_stores", ["completed_at"], :name => "index_orders_stores_on_completed_at"
  add_index "orders_stores", ["order_id", "store_id"], :name => "index_orders_stores_on_order_id_and_store_id", :unique => true
  add_index "orders_stores", ["order_id"], :name => "index_orders_stores_on_order_id"
  add_index "orders_stores", ["state"], :name => "index_orders_stores_on_state"
  add_index "orders_stores", ["store_id"], :name => "index_orders_stores_on_store_id"
  add_index "orders_stores", ["vendor_payment_period_id"], :name => "index_orders_stores_on_vendor_payment_period_id"

  create_table "paypal_accounts", :force => true do |t|
    t.string "email"
    t.string "payer_id"
    t.string "payer_country"
    t.string "payer_status"
  end

  create_table "promotions", :force => true do |t|
    t.string   "code"
    t.string   "description"
    t.integer  "usage_limit"
    t.boolean  "combine"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "starts_at"
    t.string   "match_policy", :default => "all"
    t.string   "name"
    t.integer  "store_id"
    t.integer  "product_id"
    t.datetime "deleted_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shoutouts", :force => true do |t|
    t.integer  "poster_id",      :null => false
    t.string   "poster_type",    :null => false
    t.integer  "posted_to_id",   :null => false
    t.string   "posted_to_type", :null => false
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spree_activators", :force => true do |t|
    t.string   "description"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "starts_at"
    t.string   "name"
    t.string   "event_name"
    t.string   "type"
    t.integer  "usage_limit"
    t.string   "match_policy", :default => "all"
    t.string   "code"
    t.boolean  "advertise",    :default => false
    t.integer  "store_id"
    t.integer  "product_id"
    t.datetime "deleted_at"
    t.string   "path"
  end

  add_index "spree_activators", ["product_id"], :name => "index_spree_activators_on_product_id"
  add_index "spree_activators", ["store_id"], :name => "index_spree_activators_on_store_id"

  create_table "spree_addresses", :force => true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.integer  "state_id"
    t.string   "zipcode"
    t.integer  "country_id"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state_name"
    t.string   "alternative_phone"
    t.string   "company"
  end

  add_index "spree_addresses", ["firstname"], :name => "index_addresses_on_firstname"
  add_index "spree_addresses", ["lastname"], :name => "index_addresses_on_lastname"

  create_table "spree_adjustments", :force => true do |t|
    t.integer  "adjustable_id"
    t.decimal  "amount",          :precision => 8, :scale => 2
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_id"
    t.string   "source_type"
    t.boolean  "mandatory"
    t.boolean  "locked"
    t.integer  "originator_id"
    t.string   "originator_type"
    t.boolean  "eligible",                                      :default => true
    t.string   "adjustable_type"
  end

  add_index "spree_adjustments", ["adjustable_id"], :name => "index_adjustments_on_order_id"

  create_table "spree_assets", :force => true do |t|
    t.integer  "viewable_id"
    t.string   "viewable_type",           :limit => 50
    t.string   "attachment_content_type"
    t.string   "attachment_file_name"
    t.integer  "attachment_size"
    t.integer  "position"
    t.string   "type",                    :limit => 75
    t.datetime "attachment_updated_at"
    t.integer  "attachment_width"
    t.integer  "attachment_height"
    t.text     "alt"
    t.boolean  "featured",                              :default => false, :null => false
    t.integer  "version",                               :default => 0
  end

  add_index "spree_assets", ["viewable_id", "viewable_type", "type"], :name => "index_assets_on_viewable_id_and_viewable_type_and_type"

  create_table "spree_calculators", :force => true do |t|
    t.string   "type"
    t.integer  "calculable_id",   :null => false
    t.string   "calculable_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spree_configurations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",       :limit => 50
  end

  add_index "spree_configurations", ["name", "type"], :name => "index_configurations_on_name_and_type"

  create_table "spree_countries", :force => true do |t|
    t.string  "iso_name"
    t.string  "iso"
    t.string  "name"
    t.string  "iso3"
    t.integer "numcode"
  end

  create_table "spree_creditcards", :force => true do |t|
    t.string   "month"
    t.string   "year"
    t.string   "cc_type"
    t.string   "last_digits"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "start_month"
    t.string   "start_year"
    t.string   "issue_number"
    t.integer  "address_id"
    t.string   "gateway_customer_profile_id"
    t.string   "gateway_payment_profile_id"
  end

  create_table "spree_gateways", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "description"
    t.boolean  "active",      :default => true
    t.string   "environment", :default => "development"
    t.string   "server",      :default => "test"
    t.boolean  "test_mode",   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spree_inventory_units", :force => true do |t|
    t.integer  "variant_id"
    t.integer  "order_id"
    t.string   "state"
    t.integer  "lock_version",               :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipment_id"
    t.integer  "return_authorization_id"
    t.integer  "line_item_id"
    t.datetime "canceled_at"
    t.integer  "canceled_by"
    t.integer  "vendor_payment_reversal_id"
  end

  add_index "spree_inventory_units", ["canceled_at"], :name => "index_inventory_units_on_canceled_at"
  add_index "spree_inventory_units", ["canceled_by"], :name => "index_inventory_units_on_canceled_by"
  add_index "spree_inventory_units", ["line_item_id"], :name => "index_inventory_units_on_line_item_id"
  add_index "spree_inventory_units", ["order_id"], :name => "index_inventory_units_on_order_id"
  add_index "spree_inventory_units", ["shipment_id"], :name => "index_inventory_units_on_shipment_id"
  add_index "spree_inventory_units", ["variant_id"], :name => "index_inventory_units_on_variant_id"

  create_table "spree_line_items", :force => true do |t|
    t.integer  "order_id"
    t.integer  "variant_id"
    t.integer  "quantity",                                                                    :null => false
    t.decimal  "price",                      :precision => 8, :scale => 2,                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "store_id"
    t.string   "state"
    t.decimal  "total_amount",               :precision => 8, :scale => 2, :default => 0.0,   :null => false
    t.decimal  "commission_percentage",      :precision => 5, :scale => 2, :default => 0.0,   :null => false
    t.decimal  "store_amount",               :precision => 8, :scale => 2, :default => 0.0,   :null => false
    t.datetime "canceled_at"
    t.integer  "canceled_by"
    t.boolean  "commission_percentage_lock"
    t.boolean  "on_sale",                                                  :default => false, :null => false
  end

  add_index "spree_line_items", ["canceled_at"], :name => "index_line_items_on_canceled_at"
  add_index "spree_line_items", ["canceled_by"], :name => "index_line_items_on_canceled_by"
  add_index "spree_line_items", ["order_id"], :name => "index_line_items_on_order_id"
  add_index "spree_line_items", ["state"], :name => "index_line_items_on_state"
  add_index "spree_line_items", ["store_id"], :name => "index_line_items_on_store_id"
  add_index "spree_line_items", ["variant_id"], :name => "index_line_items_on_variant_id"

  create_table "spree_log_entries", :force => true do |t|
    t.integer  "source_id"
    t.string   "source_type"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spree_mail_methods", :force => true do |t|
    t.string   "environment"
    t.boolean  "active",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spree_option_types", :force => true do |t|
    t.string   "name",         :limit => 100
    t.string   "presentation", :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",                    :default => 0, :null => false
  end

  create_table "spree_option_types_prototypes", :id => false, :force => true do |t|
    t.integer "prototype_id"
    t.integer "option_type_id"
  end

  create_table "spree_option_values", :force => true do |t|
    t.integer  "option_type_id"
    t.string   "name"
    t.integer  "position"
    t.string   "presentation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spree_option_values_variants", :id => false, :force => true do |t|
    t.integer "variant_id"
    t.integer "option_value_id"
  end

  add_index "spree_option_values_variants", ["variant_id", "option_value_id"], :name => "index_option_values_variants_on_variant_id_and_option_value_id"
  add_index "spree_option_values_variants", ["variant_id"], :name => "index_option_values_variants_on_variant_id"

  create_table "spree_orders", :force => true do |t|
    t.integer  "user_id"
    t.string   "number",               :limit => 15
    t.decimal  "item_total",                         :precision => 8, :scale => 2, :default => 0.0,  :null => false
    t.decimal  "total",                              :precision => 8, :scale => 2, :default => 0.0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.decimal  "adjustment_total",                   :precision => 8, :scale => 2, :default => 0.0,  :null => false
    t.decimal  "credit_total",                       :precision => 8, :scale => 2, :default => 0.0,  :null => false
    t.datetime "completed_at"
    t.integer  "bill_address_id"
    t.integer  "ship_address_id"
    t.decimal  "payment_total",                      :precision => 8, :scale => 2, :default => 0.0
    t.integer  "shipping_method_id"
    t.string   "shipment_state"
    t.string   "payment_state"
    t.string   "email"
    t.text     "special_instructions"
    t.boolean  "use_bill_address",                                                 :default => true
    t.datetime "canceled_at"
    t.integer  "canceled_by"
  end

  add_index "spree_orders", ["canceled_at"], :name => "index_orders_on_canceled_at"
  add_index "spree_orders", ["canceled_by"], :name => "index_orders_on_canceled_by"
  add_index "spree_orders", ["number"], :name => "index_orders_on_number"

  create_table "spree_payment_methods", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "description"
    t.boolean  "active",      :default => true
    t.string   "environment", :default => "development"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "display_on"
  end

  create_table "spree_payments", :force => true do |t|
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount",                   :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "payment_method_id"
    t.string   "state"
    t.string   "response_code"
    t.string   "avs_response"
    t.string   "type"
    t.integer  "vendor_payment_period_id"
    t.integer  "admin_id"
    t.decimal  "product_sales",            :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "coupons",                  :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "shipping",                 :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "sales_tax",                :precision => 8, :scale => 2, :default => 0.0
    t.text     "response_data"
  end

  create_table "spree_pending_promotions", :force => true do |t|
    t.integer "user_id"
    t.integer "promotion_id"
  end

  add_index "spree_pending_promotions", ["promotion_id"], :name => "index_spree_pending_promotions_on_promotion_id"
  add_index "spree_pending_promotions", ["user_id"], :name => "index_spree_pending_promotions_on_user_id"

  create_table "spree_preferences", :force => true do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "key"
    t.string   "value_type"
  end

  add_index "spree_preferences", ["key"], :name => "index_spree_preferences_on_key", :unique => true

  create_table "spree_product_groups", :force => true do |t|
    t.string "name"
    t.string "permalink"
    t.string "order"
  end

  add_index "spree_product_groups", ["name"], :name => "index_product_groups_on_name"
  add_index "spree_product_groups", ["permalink"], :name => "index_product_groups_on_permalink"

  create_table "spree_product_groups_products", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "product_group_id"
  end

  create_table "spree_product_option_types", :force => true do |t|
    t.integer  "product_id"
    t.integer  "option_type_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spree_product_option_types", ["product_id", "option_type_id"], :name => "index_product_option_types_on_product_id_and_option_type_id", :unique => true

  create_table "spree_product_properties", :force => true do |t|
    t.integer  "product_id"
    t.integer  "property_id"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spree_product_properties", ["product_id"], :name => "index_product_properties_on_product_id"

  create_table "spree_product_scopes", :force => true do |t|
    t.integer "product_group_id"
    t.string  "name"
    t.text    "arguments"
  end

  add_index "spree_product_scopes", ["name"], :name => "index_product_scopes_on_name"
  add_index "spree_product_scopes", ["product_group_id"], :name => "index_product_scopes_on_product_group_id"

  create_table "spree_products", :force => true do |t|
    t.string   "name",                                      :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
    t.datetime "available_on"
    t.integer  "tax_category_id"
    t.integer  "shipping_category_id"
    t.datetime "deleted_at"
    t.string   "meta_description"
    t.string   "meta_keywords"
    t.integer  "count_on_hand",        :default => 0,       :null => false
    t.integer  "product_id"
    t.string   "state",                :default => "draft", :null => false
    t.integer  "user_id"
    t.string   "type"
    t.integer  "featured_image_id"
    t.integer  "brand_id"
    t.float    "rating"
    t.integer  "page_views",           :default => 0
    t.datetime "rated_at"
  end

  add_index "spree_products", ["available_on"], :name => "index_products_on_available_on"
  add_index "spree_products", ["brand_id"], :name => "index_products_on_brand_id"
  add_index "spree_products", ["deleted_at"], :name => "index_products_on_deleted_at"
  add_index "spree_products", ["featured_image_id"], :name => "index_products_on_featured_image_id"
  add_index "spree_products", ["name"], :name => "index_products_on_name"
  add_index "spree_products", ["permalink"], :name => "index_products_on_permalink"
  add_index "spree_products", ["product_id"], :name => "index_products_on_product_id"
  add_index "spree_products", ["shipping_category_id"], :name => "index_products_on_shipping_category_id"
  add_index "spree_products", ["state"], :name => "index_products_on_status"
  add_index "spree_products", ["tax_category_id"], :name => "index_products_on_tax_category_id"

  create_table "spree_products_promotion_rules", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "promotion_rule_id"
  end

  add_index "spree_products_promotion_rules", ["product_id"], :name => "index_products_promotion_rules_on_product_id"
  add_index "spree_products_promotion_rules", ["promotion_rule_id"], :name => "index_products_promotion_rules_on_promotion_rule_id"

  create_table "spree_products_taxons", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "taxon_id"
  end

  add_index "spree_products_taxons", ["product_id"], :name => "index_products_taxons_on_product_id"
  add_index "spree_products_taxons", ["taxon_id"], :name => "index_products_taxons_on_taxon_id"

  create_table "spree_promotion_action_line_items", :force => true do |t|
    t.integer "promotion_action_id"
    t.integer "variant_id"
    t.integer "quantity",            :default => 1
  end

  create_table "spree_promotion_actions", :force => true do |t|
    t.integer "activator_id"
    t.integer "position"
    t.string  "type"
  end

  create_table "spree_promotion_rules", :force => true do |t|
    t.integer  "activator_id"
    t.integer  "user_id"
    t.integer  "product_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "spree_promotion_rules", ["activator_id"], :name => "index_spree_promotion_rules_on_activator_id"
  add_index "spree_promotion_rules", ["product_group_id"], :name => "index_promotion_rules_on_product_group_id"
  add_index "spree_promotion_rules", ["user_id"], :name => "index_promotion_rules_on_user_id"

  create_table "spree_promotion_rules_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "promotion_rule_id"
  end

  add_index "spree_promotion_rules_users", ["promotion_rule_id"], :name => "index_promotion_rules_users_on_promotion_rule_id"
  add_index "spree_promotion_rules_users", ["user_id"], :name => "index_promotion_rules_users_on_user_id"

  create_table "spree_properties", :force => true do |t|
    t.string   "name"
    t.string   "presentation", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spree_properties_prototypes", :id => false, :force => true do |t|
    t.integer "prototype_id"
    t.integer "property_id"
  end

  create_table "spree_prototypes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "taxon_id"
  end

  create_table "spree_return_authorizations", :force => true do |t|
    t.string   "number"
    t.decimal  "amount",     :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.integer  "order_id"
    t.text     "reason"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spree_roles", :force => true do |t|
    t.string "name"
  end

  create_table "spree_roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "spree_roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "spree_roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "spree_shipments", :force => true do |t|
    t.integer  "order_id"
    t.integer  "shipping_method_id"
    t.string   "tracking"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "number"
    t.decimal  "cost",                   :precision => 8, :scale => 2
    t.datetime "shipped_at"
    t.integer  "address_id"
    t.string   "state"
    t.integer  "store_id"
    t.string   "vendor_shipping_method"
    t.string   "instructions"
    t.datetime "canceled_at"
    t.integer  "canceled_by"
  end

  add_index "spree_shipments", ["canceled_at"], :name => "index_shipments_on_canceled_at"
  add_index "spree_shipments", ["canceled_by"], :name => "index_shipments_on_canceled_by"
  add_index "spree_shipments", ["number"], :name => "index_shipments_on_number"
  add_index "spree_shipments", ["store_id"], :name => "index_shipments_on_store_id"

  create_table "spree_shipping_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spree_shipping_methods", :force => true do |t|
    t.integer  "zone_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_on"
    t.integer  "shipping_category_id"
    t.boolean  "match_none"
    t.boolean  "match_all"
    t.boolean  "match_one"
  end

  create_table "spree_state_events", :force => true do |t|
    t.integer  "stateful_id"
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "previous_state"
    t.string   "stateful_type"
    t.string   "next_state"
  end

  create_table "spree_states", :force => true do |t|
    t.string  "name"
    t.string  "abbr"
    t.integer "country_id"
  end

  create_table "spree_tax_categories", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_default",  :default => false
    t.datetime "deleted_at"
  end

  create_table "spree_tax_rates", :force => true do |t|
    t.integer  "zone_id"
    t.decimal  "amount",            :precision => 8, :scale => 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tax_category_id"
    t.boolean  "included_in_price",                               :default => false
  end

  create_table "spree_taxonomies", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spree_taxons", :force => true do |t|
    t.integer  "taxonomy_id",                                                    :null => false
    t.integer  "parent_id"
    t.integer  "position",                                        :default => 0
    t.string   "name",                                                           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.text     "description"
    t.string   "founded"
    t.string   "email"
    t.string   "location"
    t.text     "company_overview"
    t.text     "about"
    t.text     "mission"
    t.text     "product_types"
    t.text     "team_members"
    t.string   "meta_keywords"
    t.string   "meta_description"
    t.boolean  "menu_item"
    t.string   "facebook_id"
    t.string   "facebook_name"
    t.string   "facebook_link"
    t.string   "username"
    t.integer  "store_id"
    t.decimal  "commission_rate",   :precision => 5, :scale => 2
  end

  add_index "spree_taxons", ["parent_id"], :name => "index_taxons_on_parent_id"
  add_index "spree_taxons", ["permalink"], :name => "index_taxons_on_permalink"
  add_index "spree_taxons", ["taxonomy_id"], :name => "index_taxons_on_taxonomy_id"
  add_index "spree_taxons", ["username"], :name => "index_taxons_on_username", :unique => true

  create_table "spree_tokenized_permissions", :force => true do |t|
    t.integer  "permissable_id"
    t.string   "permissable_type"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spree_tokenized_permissions", ["permissable_id", "permissable_type"], :name => "index_tokenized_name_and_type"

  create_table "spree_trackers", :force => true do |t|
    t.string   "environment"
    t.string   "analytics_id"
    t.boolean  "active",       :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spree_user_authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "nickname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "access_token"
  end

  create_table "spree_users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "password_salt"
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "persistence_token"
    t.string   "reset_password_token"
    t.string   "perishable_token"
    t.integer  "sign_in_count",         :default => 0,     :null => false
    t.integer  "failed_attempts",       :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "login"
    t.integer  "ship_address_id"
    t.integer  "bill_address_id"
    t.string   "authentication_token"
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "remember_created_at"
    t.text     "about"
    t.string   "current_city"
    t.string   "name"
    t.date     "birthday"
    t.string   "gender"
    t.text     "favorite_brands"
    t.text     "favorite_sneakers"
    t.text     "favorite_street_shops"
    t.boolean  "facebook_manage_pages"
    t.string   "username"
    t.string   "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.boolean  "opt_in_email",          :default => false, :null => false
    t.integer  "receive_emails",        :default => 0
    t.integer  "followers_count",       :default => 0
  end

  add_index "spree_users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "spree_users", ["opt_in_email"], :name => "index_users_on_opt_in_email"
  add_index "spree_users", ["persistence_token"], :name => "index_users_on_persistence_token"
  add_index "spree_users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "spree_variants", :force => true do |t|
    t.integer  "product_id"
    t.string   "sku",                                                            :null => false
    t.decimal  "price",         :precision => 8, :scale => 2,                    :null => false
    t.decimal  "weight",        :precision => 8, :scale => 2
    t.decimal  "height",        :precision => 8, :scale => 2
    t.decimal  "width",         :precision => 8, :scale => 2
    t.decimal  "depth",         :precision => 8, :scale => 2
    t.datetime "deleted_at"
    t.boolean  "is_master",                                   :default => false
    t.integer  "count_on_hand",                               :default => 0,     :null => false
    t.decimal  "cost_price",    :precision => 8, :scale => 2
    t.integer  "position"
    t.integer  "parent_id"
    t.decimal  "sale_price",    :precision => 8, :scale => 2, :default => 0.0
    t.datetime "sale_start_at"
    t.datetime "sale_end_at"
  end

  add_index "spree_variants", ["product_id"], :name => "index_variants_on_product_id"

  create_table "spree_zone_members", :force => true do |t|
    t.integer  "zone_id"
    t.integer  "zoneable_id"
    t.string   "zoneable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spree_zones", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "default_tax", :default => false
  end

  create_table "store_tiers", :force => true do |t|
    t.string   "name",                                                      :null => false
    t.decimal  "discount",   :precision => 5, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stores", :force => true do |t|
    t.text     "description"
    t.string   "founded"
    t.string   "email"
    t.string   "location"
    t.text     "company_overview"
    t.text     "about"
    t.text     "mission"
    t.text     "product_types"
    t.text     "team_members"
    t.string   "meta_keywords"
    t.string   "meta_description"
    t.string   "facebook_id"
    t.string   "facebook_name"
    t.string   "facebook_link"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "feedback_rating",                        :precision => 2, :scale => 1
    t.integer  "store_tier_id"
    t.text     "policies"
    t.text     "return_policies"
    t.string   "customer_support"
    t.string   "customer_support_phone"
    t.integer  "usa_epay_customer_number"
    t.integer  "followers_count",                                                      :default => 0
    t.string   "state",                    :limit => 50
  end

  add_index "stores", ["store_tier_id"], :name => "index_stores_on_store_tier_id"
  add_index "stores", ["username"], :name => "index_stores_on_username", :unique => true

  create_table "stores_users", :id => false, :force => true do |t|
    t.integer "store_id"
    t.integer "user_id"
    t.boolean "facebook_manager"
    t.string  "facebook_access_token"
  end

  add_index "stores_users", ["store_id"], :name => "index_stores_users_on_store_id"
  add_index "stores_users", ["user_id"], :name => "index_stores_users_on_user_id"

  create_table "taxons_users", :id => false, :force => true do |t|
    t.integer "taxon_id"
    t.integer "user_id"
    t.boolean "facebook_manager"
    t.string  "facebook_access_token"
  end

  create_table "vendor_payment_periods", :force => true do |t|
    t.date     "month",                                                              :null => false
    t.string   "state",                                       :default => "not_yet", :null => false
    t.decimal  "total",         :precision => 8, :scale => 2, :default => 0.0,       :null => false
    t.decimal  "payment_total", :precision => 8, :scale => 2, :default => 0.0,       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "store_id",                                                           :null => false
  end

  add_index "vendor_payment_periods", ["month", "store_id"], :name => "index_vendor_payment_periods_on_month_and_store_id", :unique => true
  add_index "vendor_payment_periods", ["store_id"], :name => "index_vendor_payment_periods_on_store_id"

end
