require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end


module Soletronspree
  class Application < Rails::Application
    # require 'spree_site'
    
    config.to_prepare do
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    
      Dir.glob(File.join(File.dirname(__FILE__), "../app/overrides/*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end
      
      
      # 3.1Break
      # if File.basename( $0 ) != "rake"
      #         # register promotion rules
      #         [Spree::Promotion::Rules::Automatic].each &:register
      #       
      #         # register default promotion calculators
      #         [
      #           Spree::Calculator::FlexiPercent
      #         ].each{|c_model|
      #           begin
      #             Spree::Promotion.register_calculator(c_model) if c_model.table_exists?
      #           rescue Exception => e
      #             $stderr.puts "Error registering promotion calculator #{c_model}"
      #           end
      #         }
      #       end

      
      
      
    end

    config.middleware.use "Spree::Core::Middleware::RedirectLegacyProductUrl"
    config.middleware.use "Spree::Core::Middleware::SeoAssist"
  
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{Rails.root}/app/observers #{Rails.root}/app/lib #{Rails.root}/lib/seo)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    config.active_record.observers = :follow_observer, :shoutout_observer, :comment_observer, 
                                     :order_observer, 
                                     :product_observer, :favorite_observer, 
                                     :user_product_observer, :feedback_observer, :line_item_observer, 
                                     :orders_store_observer, :shipment_observer
                                     
                                     

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.assets.enabled     = true
    config.assets.version     = '1.0'
    config.assets.prefix      = "/assets"
    
    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    # order contains payment parameters so it needs to be stopped from being sent to the log file.
    config.filter_parameters += [:password, :password_confirmation, :payments_attributes, :payment_source]

    config.action_mailer.default_url_options = {:host => Rails.env.development? ? 'shop.soletron.dev:3000' : "#{ENV['SERVER']}.soletron.com"}
  end
end

# require 'paginate/array'
# require 'site_hooks'
require 'omniauth_permissions'
require Rails.root.join('lib/resource_controller_overrides')

ActionMailer::Base.smtp_settings = {
    user_name: 'soletron',
    password: 'soletronsendgrid123',
    domain: "soletron.com",
    address: 'smtp.sendgrid.net',
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true
}

# Interceptor for non-production instances
if ENV['SERVER'] != 'shop'
  require "#{Rails.root}/lib/soletron/test_mail_interceptor"
  ActionMailer::Base.register_interceptor(Soletron::TestMailInterceptor)
end

# test sourcekey

if ENV['SERVER'] == 'shop'
  USA_EPAY_SOURCE_KEY = "GBmSvC1W60N6tdmsTr3hzFy43v92G2CV"
  USA_EPAY_SOFTWARE_ID = 'DFBAABC3'
  USA_EPAY_PIN = "1111"
else
  USA_EPAY_SOURCE_KEY = "_4Rjo5h89yqwN1xCG8pwa7hiNSAnA573"
  USA_EPAY_SOFTWARE_ID = '1412E031'
  USA_EPAY_PIN = "1111"
  ActiveMerchant::Billing::Base.mode = :test
end
