class AddStatusToProducts < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
      t.string :status, :default => 'draft', :null => false
    end
    add_index :products, :status
  end

  def self.down
    change_table :products do |t|
      t.remove :status
    end
  end
end
