class ChangeFeaturedProductGroup < ActiveRecord::Migration
  def self.up
    ProductGroup.where(:name => 'Featured').each do |pg|
      pg.product_scopes.destroy_all
      pg.product_scopes.create(:name => 'active')
      pg.product_scopes.create(:name => 'with_featured_image')
    end
  end

  def self.down
    ProductGroup.where(:name => 'Featured').each do |pg|
      pg.product_scopes.destroy_all
      pg.product_scopes.create(:name => 'active')
      pg.product_scopes.create({
        :name => 'in_taxons',
        :arguments => ['Featured']
      })
    end
  end
end
