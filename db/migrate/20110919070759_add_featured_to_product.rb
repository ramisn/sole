class AddFeaturedToProduct < ActiveRecord::Migration
  def self.up
  	add_column :products, :featured_image_id, :integer
  end

  def self.down
	  remove_column :products, :featured_image_id
  end
end
