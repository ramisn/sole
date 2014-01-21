class AddSpeakersAndTanktops < ActiveRecord::Migration
  def self.up
	taxonomy_id = Taxonomy.find_by_name("Categories").id
	speakers_taxon = Taxon.find_by_name("Speakers")
	if speakers_taxon.nil?
		parent = Taxon.find_by_name("Electronics")
		speakers_taxon = Taxon.create(:name => "Speakers", :taxonomy_id => taxonomy_id,
							  :parent => parent, :position => 2, :menu_item => 1)
		speakers_taxon.save
	end
	tanktops_taxon = Taxon.find_by_name("Tank Tops")
	if tanktops_taxon.nil?
		parent = Taxon.find_by_name("Tops")
		tanktops_taxon = Taxon.create(:name => "Tank Tops", :taxonomy_id => taxonomy_id,
							  :parent => parent, :position => 8, :menu_item => 1)
		tanktops_taxon.save
	end	
  end

  def self.down
	speakers_taxon = Taxon.find_by_name("Speakers")
	unless speakers_taxon.nil?
		Taxon.destroy speakers_taxon
	end
	tanktops_taxon = Taxon.find_by_name("Tank Tops")
	unless tanktops_taxon.nil?
		Taxon.destroy tanktops_taxon
	end	
  end
end
