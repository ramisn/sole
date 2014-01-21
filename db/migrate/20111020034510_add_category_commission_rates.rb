class AddCategoryCommissionRates < ActiveRecord::Migration
  def self.up
    Taxon.find_by_name('Categories').update_attributes(:commission_rate => 30.0)
    Taxon.find_by_name('Hats').update_attributes(:commission_rate => 25.0)
    Taxon.find_by_name('Tops').update_attributes(:commission_rate => 40.0)
    # Bottoms, Footwear, Accessories, Art/Toys/Electronics, don't need to be set, because they're 30.0
    Taxon.find_by_name('Custom Sneakers').update_attributes(:commission_rate => 10.0)
  end

  def self.down
    Taxon.find_by_name('Categories').update_attributes(:commission_rate => nil)
    Taxon.find_by_name('Hats').update_attributes(:commission_rate => nil)
    Taxon.find_by_name('Tops').update_attributes(:commission_rate => nil)
    # Bottoms, Footwear, Accessories, Art/Toys/Electronics, don't need to be reset
    Taxon.find_by_name('Custom Sneakers').update_attributes(:commission_rate => nil)
  end
end
