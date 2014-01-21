namespace :cron do
  
  desc "This task updates the vendor payment statuses and vendor payment period states"
  task :daily => :environment do
    VendorPayment.update_statuses
    VendorPaymentPeriod.get_payment_periods_ready
  end
  
  desc "Update the shipment states of the orders"
  task :hourly => :environment do
    Spree::Order.update_shipment_states
  end
  
  desc "Send email to store followers regarding new items"
  task :daily => :environment do
    Product.send_email_to_followers
  end
  
  desc "Send email to stores about low quantity items"
  task :daily => :environment do
    Product.update_on_less_items
  end
  
end

desc "This task is called by the Heroku cron add-on"
task :cron => :environment do
  FeedItem.post_daily_activity_to_facebook

  Product.check_newly_added
  Product.calculate_rating!
end
