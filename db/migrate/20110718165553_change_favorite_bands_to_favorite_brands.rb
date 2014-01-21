class ChangeFavoriteBandsToFavoriteBrands < ActiveRecord::Migration
  def self.up
    rename_column :users, :favorite_bands, :favorite_brands
  end

  def self.down
    rename_column :users, :favorite_brands, :favorite_bands
  end
end
