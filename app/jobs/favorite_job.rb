class FavoriteJob < Struct.new(:favorite_id)
  
  def perform
    favorite = Favorite.find(favorite_id)
    product = favorite.product
    store = product.master.product.store
    store.users.each do |manager|
      FavoriteMailer.delay.product_favorited(favorite, manager)
    end
  end
  
end
