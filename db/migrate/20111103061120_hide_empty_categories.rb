class HideEmptyCategories < ActiveRecord::Migration
  def self.up
    Taxon.find_all_by_taxonomy_id(Taxonomy.find_by_name("Categories")).each do |taxon|
      puts "**** examining taxon #{taxon.name}"
      if taxon.children.empty?     # only look at leaf nodes
        taxon.menu_item = !taxon.products.active.where(:state => :published).empty?
        puts "**** taxon #{taxon.name} is a menu item? #{taxon.menu_item}"
        taxon.save
      end
    end

    Taxon.find_all_by_taxonomy_id(Taxonomy.find_by_name("Departments")).each do |taxon|
      puts "**** examining taxon #{taxon.name}"
      if taxon.children.empty?     # only look at leaf nodes
        taxon.menu_item = !taxon.products.active.where(:state => :published).empty?
        puts "**** taxon #{taxon.name} is a menu item? #{taxon.menu_item}"
        taxon.save
      end
    end
  end

  def self.down
    Taxon.all.each do |taxon|
      taxon.menu_item = true
      taxon.save
    end
  end
end
