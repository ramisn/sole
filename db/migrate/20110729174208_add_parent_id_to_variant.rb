class AddParentIdToVariant < ActiveRecord::Migration
  def self.up
    add_column :variants, :parent_id, :integer
  end

  def self.down
    remove_column :variants, :parent_id
  end
end
