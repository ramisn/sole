class RenameStatusToStateProductStateMachine < ActiveRecord::Migration
  def self.up
	rename_column :products, :status, :state
	Product.all.each do |product|
		product.state = "published"
		product.save
	end
  end

  def self.down
	rename_column :products, :state, :status
  end
end
