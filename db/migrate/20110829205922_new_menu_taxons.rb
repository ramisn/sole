class NewMenuTaxons < ActiveRecord::Migration
  def self.up
	taxon_names = ["Miscellaneous", "Art", "Toys"]
	taxon_names.each do |taxon_name|
		taxon = Taxon.find_by_name(taxon_name)
		if !taxon.nil?
			taxon.menu_item = true;
			taxon.save
		end
	end
  end

  def self.down
	taxon_names = ["Miscellaneous", "Art", "Toys"]
	taxon_names.each do |taxon_name|
		taxon = Taxon.find_by_name(taxon_name)
		if !taxon.nil?
			taxon.menu_item = false;
			taxon.save
		end
	end  
  end
end
