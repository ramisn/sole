class AddInstructionsToShipment < ActiveRecord::Migration
  def self.up
    add_column :shipments, :instructions, :string
  end

  def self.down
    remove_column :shipments, :instructions
  end
end
