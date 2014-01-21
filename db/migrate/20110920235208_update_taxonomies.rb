class UpdateTaxonomies < ActiveRecord::Migration
  def self.up
  
  	belts = Taxon.find_by_name("Belts")
	belts.parent = Taxon.find_by_name("Bottoms")
	belts.save
	
	socks = Taxon.find_by_name("Socks")
	socks.parent = Taxon.find_by_name("Footwear")
	socks.save
	
	otsocks = OptionType.find_by_name("sock-size")
	otfoot = OptionType.find_by_name("shoe-size")
	otfoot.option_values += otsocks.option_values
	otfoot.save
  end

  def self.down
  end
end
