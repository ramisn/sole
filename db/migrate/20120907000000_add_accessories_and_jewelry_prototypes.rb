class AddAccessoriesAndJewelryPrototypes < ActiveRecord::Migration
  def self.up
    taxon = Spree::Taxon.where(:name => "Accessories").first
    unless taxon.prototype.present?
      taxon.create_prototype(:name => "Accessories")
    end
    primary_color = Spree::OptionType.where(:name => "color1").first
    unless primary_color.nil? || taxon.prototype.option_types.include?(primary_color)
      taxon.prototype.option_types << primary_color
    end
    secondary_color = Spree::OptionType.where(:name => "color2").first
    unless secondary_color.nil? || taxon.prototype.option_types.include?(secondary_color)
      taxon.prototype.option_types << secondary_color
    end

    taxon = Spree::Taxon.where(:name => "Jewelry").first
    unless taxon.prototype.present?
      taxon.create_prototype(:name => "Jewelry")
    end
    jewelry_size = Spree::OptionType.where(:name => "jewelry-size").first
    unless jewelry_size.nil? || taxon.prototype.option_types.include?(jewelry_size)
      taxon.prototype.option_types << jewelry_size
    end
  end
end
