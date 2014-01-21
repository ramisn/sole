class UpdateSwimwearInTops < ActiveRecord::Migration
  def self.up
    @product = Spree::Taxon.find(:first, :conditions => ["name = 'Bottoms'"])
    unless @product.blank?      
      taxon = Spree::Taxon.find(:first, :conditions => ["name = 'Swimwear Tops' and taxonomy_id = ? and parent_id = ?",@product.taxonomy_id,@product.id])
      unless taxon.blank?
        taxon.update_attributes({:name => "Swimwear Bottoms", :permalink => "categories/clothing/swimwear_bottoms"})
      end
    end
  end

  def self.down
  end
end
