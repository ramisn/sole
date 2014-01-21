class CreatedProductsRatedAt < ActiveRecord::Migration
  def self.up
    add_column :products, :rated_at, :datetime
  end

  def self.down
    remove_column :products, :rated_at
  end
end