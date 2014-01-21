module FavoritesHelper
  def product_favorite_link(product)
    if current_user and current_user == @acting_as and !current_user.favorites.find_by_product_id(product.id)
      link_to image_tag('/assets/flash_soletron_fav-icon.png', :height => 24, :width => 24, :alt => 'favorite'), main_app.product_favorite_path(product.id), :class => 'favorite', :title => "Add to Favorites"
    end
  end
  
  
  def link_to_favorite(product)
    
    fav_url   =  main_app.product_favorite_path(product.id)
    unfav_url =  main_app.remove_product_from_favorites_path(product.id)
       
    if product.is_favorite_of?(current_user)
      title = 'Remove from Favs'
      label = 'unfav'
      url   = unfav_url
    else
      title = 'Add to Favorites'
      label = 'fav'
      url   = fav_url
    end
    
    link_to(title, url, :title => title, :class => "favoritable simpleButton #{label.downcase}", 'data-fav-url' => fav_url, 'data-unfav-url' => unfav_url )
    
  end
end
