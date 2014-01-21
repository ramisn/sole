class EnsureOnSaleProductGroups < ActiveRecord::Migration
  def self.up
    ProductGroup.where(:name => 'On Sale').each do |pg|
      pg.product_scopes.destroy_all
      pg.product_scopes.create(:name => 'active')
      pg.product_scopes.create(:name => 'sale')
      pg.save!
    end
  end

  def self.down
    # The migration does nothing but ensures.
  end
end
