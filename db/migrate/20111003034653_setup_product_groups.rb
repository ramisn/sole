class SetupProductGroups < ActiveRecord::Migration

  def self.up
    group = ProductGroup.find_or_create_by_name("On Sale")
    group.product_scopes.destroy_all
    scope = group.product_scopes.create(:name => "active")
    scope = group.product_scopes.create(:name => "in_taxons", :arguments => ["On Sale"])

    group = ProductGroup.find_or_create_by_name("Newly Added")
    group.product_scopes.destroy_all
    scope = group.product_scopes.create(:name => "active")
    scope = group.product_scopes.create(:name => "newly_added")

    group = ProductGroup.find_or_create_by_name("Featured")
    group.product_scopes.destroy_all
    scope = group.product_scopes.create(:name => "active")
    scope = group.product_scopes.create(:name => "in_taxons", :arguments => ["Featured"])

    group = ProductGroup.find_or_create_by_name("Custom Products")
    group.product_scopes.destroy_all
    scope = group.product_scopes.create(:name => "active")
    scope = group.product_scopes.create(:name => "in_taxons", :arguments => ["Custom Products"])
  end

  def self.down
  end

end
