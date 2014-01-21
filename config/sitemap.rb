# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://shop.soletron.com"


SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
 
  def entity_followers_path(entity)
    case entity
    when Spree::User
      main_app.followers_member_path(entity)
    when Store
      main_app.followers_store_path(entity)
    else
      "#"
    end
  end
  
  def entity_following_path(entity)
    case entity
    when Spree::User
      main_app.following_member_path(entity)
    when Store
      main_app.following_store_path(entity)
    else
      "#"
    end
  end
 
  def seo_url(taxon, product = nil)
    return '/t/' + taxon.permalink if product.nil?
    warn "DEPRECATION: the /t/taxon-permalink/p/product-permalink urls are "+
      "not used anymore. Use product_url instead. (called from #{caller[0]})"
    return spree.product_url(product)
  end
  
  add '/products'
  Spree::Product.viewable.find_each do |product|
	if !(product.nil? || product.store.nil?)
		add product_path(product), :lastmod => product.updated_at
    end
  end
  
  add '/stores'
  Store.find_each do |store|
	if !(store.nil?)
		add main_app.store_path(store), :lastmod => store.updated_at
		add main_app.store_feed_path(store), :lastmod => store.updated_at
		add main_app.about_store_path(store), :lastmod => store.updated_at
		add main_app.store_feedbacks_path(store), :lastmod => store.updated_at
		add main_app.policies_store_path(store), :lastmod => store.updated_at
		add main_app.entity_followers_path(store), :lastmod => store.updated_at
		add main_app.entity_following_path(store), :lastmod => store.updated_at
   end
end

  
  add '/members'
  Spree::User.find_each do |user|
		add main_app.member_path(user), :lastmod => user.updated_at
		add main_app.member_collection_path(user), :lastmod => user.updated_at
		add main_app.about_member_path(user), :lastmod => user.updated_at
		add main_app.member_feedbacks_path(user), :lastmod => user.updated_at
		add main_app.entity_followers_path(user), :lastmod => user.updated_at
		add main_app.entity_following_path(user), :lastmod => user.updated_at
 end
  
  add '/t/categories'
  Spree::Taxon.find_each do |taxon|
		add seo_url(taxon), :lastmod => taxon.updated_at
  end
end
