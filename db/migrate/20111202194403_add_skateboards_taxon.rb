class AddSkateboardsTaxon < ActiveRecord::Migration
  def self.up
    taxon = Taxon.find_by_name("Skateboards")
    if taxon.nil?
      parent = Taxon.find_by_name("Miscellaneous")
      taxon = Taxon.create(:name => "Skateboards", :taxonomy_id => Taxonomy.find_by_name("Categories").id,
              :parent => parent, :position => 4, :menu_item => 0)
      taxon.save
    end
  end

  def self.down
    taxon = Taxon.find_by_name("Skateboards")
    unless taxon.nil?
      Taxon.destroy taxon
    end
  end
end
