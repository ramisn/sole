class RemoveCustomProductGroup < ActiveRecord::Migration
  def self.up
    ProductGroup.where(:name => 'Custom Products').each do |pg|
      pg.destroy
    end
  end

  def self.down
    group = ProductGroup.find_or_create_by_name("Custom Products")
    group.product_scopes.destroy_all

    scope = group.product_scopes.create(:name => "active")
    scope = group.product_scopes.create({
      :name => "in_taxons",
      :arguments => ["Custom Products"]
    })
  end
end
