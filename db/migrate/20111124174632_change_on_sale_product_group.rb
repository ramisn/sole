class ChangeOnSaleProductGroup < ActiveRecord::Migration
  def self.up
    ProductGroup.where(:name => 'On Sale').each do |pg|
      pg.product_scopes.destroy_all
      
      pg.product_scopes.create(:name => 'active')
      pg.product_scopes.create(:name => 'sale')
    end
  end

  def self.down
    ProductGroup.where(:name => 'On Sale').each do |pg|
      pg.product_scopes.destroy_all
      
      pg.product_scopes.create(:name => 'active')
      pg.product_scopes.create({
        :name => 'in_taxons',
        :arguments => ['On Sale']
      })
    end
  end
end
