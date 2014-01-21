class FixCapitalizationCustomHats < ActiveRecord::Migration
  def self.up
	taxon = Taxon.find_by_name("Custom hats")
	if !taxon.nil?
		taxon.name = "Custom Hats"
		taxon.save
	end
  end

  def self.down
	taxon = Taxon.find_by_name("Custom Hats")
	if !taxon.nil?
		taxon.name = "Custom hats"
		taxon.save
	end  
  end
end
