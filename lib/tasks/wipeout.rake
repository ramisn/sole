namespace :db do
  task :wipeout => :environment do
    desc "Clear out all sample and old testing data from the database"

    print "This action will remove all the data from your local Soletron database."
      # Destroy all the Stores
      puts "Destroying stores"
      Store.destroy_all

      # Destroy and abandoned Store taxons
      store_taxons = Taxon.find_all_by_taxonomy_id(Taxonomy.find_by_name("Stores").id)
      store_taxons.each do |taxon|
        if !taxon.parent_id.nil?
          taxon.destroy
        end
      end

      # Destroy all products and their variants
      puts "Destroying all products and their variants"
      Product.destroy_all

      # Destroy any abandoned iamges and other assets
      puts "Destroying all assets (images, etc.)"
      Asset.destroy_all

      # Destroy all users - preserve arielle, jerod, and spree
      emails_to_preserve = ["spree@example.com", "arielle@framihowe.org", "jerod@huels.com"]

      puts "Destroying all users (except for arielle, jerod, and spree)"
      Spree::User.all.each do |user|
        if emails_to_preserve.index(user.email).nil?
          user.destroy
        end
      end

      #Destroy all other built-in data, provided by Spree

      puts "Destroying InventoryUnits, Payments, Option Types, Properies, Prototypes, and Shipment records. Deleting Line Items and Orders"
      InventoryUnit.destroy_all
      LineItem.delete_all		# can't destroy line items and orders after destroying Variants - Line Items and Orders try to access
      Spree::Order.delete_all		# variants, while Variant.destroy doesn't appear to remove the appropriate Line Item and Spree::Order records
      Payment.destroy_all
      ProductOptionType.destroy_all
      ProductProperty.destroy_all
      Prototype.find_all_by_taxon_id(nil).each do |proto|
        proto.destroy
      end
      Shipment.destroy_all

      puts "Destroying all Spree built-in Option Values"
      option_type = OptionType.find_by_name("tshirt-color")
      if !option_type.nil?
        OptionValue.find_all_by_option_type_id(option_type.id).each do |ot|
          ot.destroy
        end
        option_type.destroy
      end

      option_type = OptionType.find_by_name("tshirt-size")
      if !option_type.nil?
        OptionValue.find_all_by_option_type_id(option_type.id).each do |ot|
          ot.destroy
        end
        option_type.destroy
      end

      puts "Destroying all Brand taxons"
      brand_taxons = Taxon.find_all_by_taxonomy_id(Taxonomy.find_by_name("Brand").id)
      brand_taxons.each do |taxon|
        if !taxon.parent_id.nil?
          taxon.destroy
        end
      end

      puts "Destroying all Spree built in Product Category taxons"
      taxons_delete = ["Shirts", "T-Shirts", "Mugs", "Bags"]
      taxons_delete.each do |name|
        taxon = Taxon.find_by_name(name)
        taxon.destroy unless taxon.nil?
      end
  end
end