class SitemapController < ApplicationController
  def index
    render :layout => "sitemap"
    
    
			xml.instruct!
		xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do

			  xml.url do
				xml.loc "http://shop.soletron.com"
				xml.priority 1.0
			  end

		  

		end
    
    
  end

end
