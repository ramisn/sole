class AddNewCategoryToCategories < ActiveRecord::Migration
  def self.up
   @product = Taxon.find(:first, :conditions => ["name = 'Tops'"])
    unless @product.blank?
      Taxon.new({:taxonomy_id => @product.taxonomy_id, :parent_id => @product.id,:position => 5, :name => "Swimwear Tops", :permalink => "categories/clothing/swimwear_tops", :lft => '44', :rgt => '45', :menu_item => 1}).save
    end
    
    @product = Taxon.find(:first, :conditions => ["name = 'Bottoms'"])
    unless @product.blank?
      Taxon.new({:taxonomy_id => @product.taxonomy_id, :parent_id => @product.id,:position => 5, :name => "Swimwear Tops", :permalink => "categories/clothing/swimwear_tops", :lft => '44', :rgt => '45', :menu_item => 1}).save
    end
 
    option_type = OptionType.new("name" => "swimwear-size","presentation" => 'Size')
    if option_type.save
      opt_id = option_type.id
      opt1 = OptionValue.new(:option_type_id => opt_id, :name => "sizeswXS", :position => 1, :presentation => "XS")
      opt1.save
      
      opt2 = OptionValue.new(:option_type_id => opt_id, :name => "sizeswS", :position => 2, :presentation => "S")
      opt2.save
      
      opt3 = OptionValue.new(:option_type_id => opt_id, :name => "sizeswM", :position => 3, :presentation => "M")
      opt3.save
      
      opt4 = OptionValue.new(:option_type_id => opt_id, :name => "sizeswL", :position => 4, :presentation => "L")
      opt4.save
      
      opt = OptionValue.new(:option_type_id => opt_id, :name => "sizeswXL", :position => 5, :presentation => "XL")
      opt.save
    end
    
  end

  def self.down
  end
end
