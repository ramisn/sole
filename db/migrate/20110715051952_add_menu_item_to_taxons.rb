class AddMenuItemToTaxons < ActiveRecord::Migration
  def self.up
    change_table :taxons do |t|
      t.boolean :menu_item
    end
  end

  def self.down
    change_table :taxons do |t|
      t.remove :menu_item
    end
  end
end
