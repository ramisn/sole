class RedirectsController < Spree::BaseController
  def index
    target = main_app.root_path
    puts "**** redirecting with params #{params}"
    if !params[:q].nil?
      case params[:q]
      when "advertise"
        target = "https://www.soletron.com/company/advertise.php"
      when "iphone"
        target = "https://www.soletron.com/company/iphone.php"
      when "home"
        target = "https://www.soletron.com"
      when "FAQhome"
        target = "https://www.soletron.com/forum/faq.php"
      when "sell"
        target = "https://www.soletron.com/sell"
      when "blog"
        search = params["query"].nil? ? "" : "?s=#{params['query']}"
        target = "http://www.soletron.com/blog" + search
      when "terms"
        target = "https://www.soletron.com/company/terms_of_use.php"
      when "privacy"
        target = "https://www.soletron.com/company/privacy_policy.php"
      when "partners"
        target = "https://www.soletron.com/company/synergetic.php"
      when "press"
        target = "https://www.soletron.com/company/press_releases.php"
      when "careers"
        target = "https://www.soletron.com/company/careers.php"
      when "contact"
        target = "https://www.soletron.com/company/contact_us.php"
      when "about"
        target = "https://www.soletron.com/company/index.php"
      when "forum"
        target = "https://www.soletron.com/forum/"
      when "adNooka"
        target = "https://www.soletron.com/adSystem/redirect.php?ad=11"
      when "adExplore"
        target = "https://www.soletron.com/adSystem/redirect.php?ad=36"
      when "adDepartments"
        target = "https://www.soletron.com/adSystem/redirect.php?ad=41"
      when "adFootwear"
        target = "https://www.soletron.com/adSystem/redirect.php?ad=40"
      when "adTops"
        target = "https://www.soletron.com/adSystem/redirect.php?ad=39"
      when "adBottoms"
        target = "https://www.soletron.com/adSystem/redirect.php?ad=38"
      when "adHats"
        target = "https://www.soletron.com/adSystem/redirect.php?ad=37"
      when "adAccessories"
        target = "https://www.soletron.com/adSystem/redirect.php?ad=35"
      when "adToys"
        target = "https://www.soletron.com/adSystem/redirect.php?ad=34"
      when "impressions"
        target = "https://www.soletron.com/adSystem/index.php?size=small-drop"
      when "faq_home"
        target = "https://www.soletron.com/forum/faq.php"
      when "FAQshipping"
        target = "https://www.soletron.com/forum/faq.php?faq=shipping_ordertracking"        
      when "forumSearch"
        search = params["query"].nil? ? "" : "&query=#{params['query']}"
        target = "https://www.soletron.com/forum/search.php?do=process" + search 
      when "FAQlookup"
        varname = params["varname"].nil? ? "" : "&varname=#{params['varname']}"
        target = "https://www.soletron.com/faq_search.php?" + varname + "&redirect=1"
      end
    end
    redirect_to target
  end
end
