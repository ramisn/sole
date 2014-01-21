Spree::ProductsHelper.module_eval do
  def taxon_preview(taxon, max=4)
    products = filter_products(taxon, max)
    if (products.size < max) && Spree::Config[:show_descendents]
      taxon.descendants.each do |t|
        to_get = max - products.length
        products += filter_products(t, to_get)
        break if products.size >= max
      end
    end
    products
  end

  def filter_products(taxon, max=4)
    if (params[:filter].nil? && params[:color1].nil? && params[:color2].nil? && params[:sex].nil? &&
        params[:size].nil? && params[:price_low].nil? && params[:price_high].nil? && params[:price_between].nil?)
      products = taxon.active_products.limit(max)
    else
      products = Product.apply_filters(params, taxon)
      products.uniq!
      products = products[0..(max-1)]
    end
    products
  end

end