class AddSomeIndicesToAssets < ActiveRecord::Migration
  def self.up
    remove_index(:assets, :viewable_id)
    remove_index(:assets, [:viewable_type, :type])

    add_index :assets, [:viewable_id, :viewable_type, :type]
  end

  def self.down
    remove_index :assets, :column => [:viewable_id, :viewable_type, :type]
    
    add_index(:assets, :viewable_id)
    add_index(:assets, [:viewable_type, :type])
  end
end