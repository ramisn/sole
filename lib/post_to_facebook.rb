require 'model_request_info'

module PostToFacebook
  include ModelRequestInfo::ModelMethods
  include Rails.application.routes.url_helpers
  
  def facebook_access_token(options={})
    raise "Method not implemented!"
  end
  
  def facebook_poster_id(options={})
    raise "Method not implemented!"
  end
  
  def facebook_name(options={})
    raise "Method not implemented!"
  end
  
  def facebook_message(options={})
    raise "Method not implemented!"
  end
  
  def facebook_link(options={})
    raise "Method not implemented!"
  end
  
  def facebook_picture_to_use(options={})
    raise "Method not implemented!"
  end
  
  def facebook_description(options={})
    raise "Method not implemented!"
  end
  
  def facebook_domain_posted_from
    if !Rails.env.production? and !Rails.env.staging?
      "http://shop.soletron.dev:3000"
    elsif ENV['SERVER'] != ''
      "http://#{ENV['SERVER']}.soletron.com"
    else
      "http://hollow-window-298.heroku.com"
    end
  end
  
  def default_url_options
    {:host => facebook_domain_posted_from}
  end
  
  def post_to_facebook(options={})
    if facebook_access_token(options) and facebook_poster_id(options)
      begin
        graph = Koala::Facebook::GraphAPI.new(facebook_access_token(options))
        
        description = facebook_description(options)
        if description.blank?
          description = "Soletron is a social marketplace and information source for exclusive sneakers, apparel, street art and the latest hip hop releases."
        end
        
        # post on the follower's wall that they have favorited a product
        graph.put_object(facebook_poster_id(options), 
                        "feed",
                        :message => facebook_message(options),
                        :link => facebook_link(options),
                        :name => facebook_name(options),
                        :picture => facebook_picture_to_use(options),
                        #:caption => "<a href=\"#{path_for_my_entity}\">#{path_for_my_entity}</a>",
                        :description => description)
      rescue Koala::Facebook::APIError => e
        if self.flash
          self.flash[:facebook] = true
        end
        false
      end
    end
  end
end
