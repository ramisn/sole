module AuthenticateHelper
  
  def authenticate_url(provider, opts={})
    options = opts.inject([]) do |array, (key, value)| 
      array << "#{key}=#{value}"
      array
    end.join('&')
    
    protocol = request.ssl? ? 'https' : 'http'
    host = if !Rails.env.production? and !Rails.env.staging?
      "shop.soletron.dev:3000"
    elsif ENV['SERVER'] != ''
      "#{ENV['SERVER']}.soletron.com"
    else
      "hollow-window-298.heroku.com"
    end
    
    "http://#{host}/user_authentications/auth/#{provider}#{options.size > 1 ? "?#{options}": ""}"
  end
  
end
