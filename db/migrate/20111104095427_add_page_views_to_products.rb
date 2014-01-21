class AddPageViewsToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :page_views, :integer, :default => 0
  end

  def self.down
    remove_column :products, :page_views
  end
end