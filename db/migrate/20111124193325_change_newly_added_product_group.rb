class ChangeNewlyAddedProductGroup < ActiveRecord::Migration
  def self.up
    ProductGroup.where(:name => 'Newly Added').each do |pg|
      pg.product_scopes.destroy_all
      pg.product_scopes.create(:name => 'active')
      pg.product_scopes.create(:name => 'newly_added')
    end
  end

  def self.down
    # The migration does nothing but ensures.
  end
end
