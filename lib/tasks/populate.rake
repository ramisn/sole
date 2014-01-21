namespace :db do
  task :populate => :environment do
    desc "Populate the Soletron database with random sample data"

    stores_taxonomy = Taxonomy.find_by_name("Stores")
    stores_taxon = Taxon.find_by_name("Stores")
    stores = []

    stores_to_create = ["Arielle's Store", "Jerod's Store", "Spree Store"]
    store_managers = ["arielle@framihowe.org", "jerod@huels.com"]
    stores_to_create.each_index do |index|
      store = Store.new

      # create the taxon for this store
      store_taxon = stores_taxonomy.taxons.build(:name => stores_to_create[index])
      store_taxon.parent_id = stores_taxon.id
      if store_taxon.save
        store.taxon = store_taxon

        # find the Users who are to be managers for this store
        manager2 = nil
        if index == 0
          manager1 = Spree::User.find_by_email(store_managers[0])
        elsif index == 1
          manager1 = Spree::User.find_by_email(store_managers[1])
        else
          manager1 = Spree::User.find_by_email(store_managers[0])
          manager2 = Spree::User.find_by_email(store_managers[1])
        end

        store.users << manager1 unless manager1.nil?
        store.users << manager2 unless manager2.nil?
        
        if store.save
            stores << store
        end
      end
    end

  end
end