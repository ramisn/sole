class AddNewProductCategories < ActiveRecord::Migration
  def self.up
    @product = Taxon.find(:first, :conditions => ["name = 'Hats'"])
    unless @product.blank?
     Taxon.new({:taxonomy_id => @product.taxonomy_id, :parent_id => @product.id,:position => 5, :name => "5 panel", :permalink => "categories/clothing/5_panel", :lft => '44', :rgt => '45', :menu_item => 1}).save
    end
    
    @product = Taxon.find(:first, :conditions => ["name = 'Electronics'"])
    unless @product.blank?
     Taxon.new({:taxonomy_id => @product.taxonomy_id, :parent_id => @product.id,:position => 3, :name => "stickers", :permalink => "categories/clothing/stickers", :lft => '90', :rgt => '91', :menu_item => 1}).save
    end
    
  end

  def self.down
  end
end
