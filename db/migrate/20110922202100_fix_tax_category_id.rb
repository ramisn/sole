class FixTaxCategoryId < ActiveRecord::Migration
  def self.up
	id = TaxCategory.find_by_name("Clothing").id
	Product.where("tax_category_id = 1").each do |p|
		p.tax_category_id = id
		p.save
	end
  end

  def self.down
  end
end
