module ProfilesHelper
  #
  # Pretty prints the day that the user Created their account
  # ex: January 17, 2011
  #
  def member_since(user)
    user.created_at.strftime("%B %e, %Y") unless user.created_at.nil?
  end
  
  def profile_picture_url(entity, opts={})
    case entity
    when Spree::User
      user_profile_picture_url(entity, opts)
    when Store
      store_profile_picture_url(entity, opts)
    when StoresUser
      store_profile_picture_url(entity.store, opts)
    end
  end
  
  # Expects a User object
  # Returns the url for the person's profile picture
  def user_profile_picture_url(user, opts={})
    size = opts[:size] || :large
    
    auths = auth_hash(user)
    pic_url = if user.profile_image
      (opts[:domain] && !user.profile_image.attachment.url(size).match(/^http/) ? opts[:domain] : '')+user.profile_image.attachment.url(size)
    # Posting to Facebook with a picture from the Facebook cdn does not work
    #elsif auths['facebook']
    #  if size == :mini
    #    size = :small
    #  elsif size == :small
    #    size = :normal
    #  elsif size == :medium
    #    size = :large
    #  end
    #  "https://graph.facebook.com/#{auths['facebook'].nickname}/picture?type=#{size}"
    else
      (opts[:domain] ? opts[:domain] : '')+"/assets/fpo-profile.jpg"
    end
    if request.ssl? and pic_url.match(/^http:/)
      pic_url.sub!(/^http:/, 'https:')
    end
    pic_url
  end
  
  # Expects a Store object
  # Returns the url for the store's profile picture
  def store_profile_picture_url(store, opts={})
    size = opts[:size] || :large
    
    pic_url = if !store.nil? && store.profile_image
      (opts[:domain] && !store.profile_image.attachment.url(size).match(/^http/) ? opts[:domain] : '')+store.profile_image.attachment.url(size)
    # Posting to Facebook with a picture from the Facebook cdn does not work
    #elsif store.facebook_id
    #  if size == :mini
    #    size = :small
    #  elsif size == :small
    #    size = :normal
    #  elsif size == :medium
    #    size = :large
    #  end
    #  "https://graph.facebook.com/#{store.facebook_id}/picture?type=#{size}"
    else
      (opts[:domain] ? opts[:domain] : '')+"/assets/fpo-profile.jpg"
    end
    if request.ssl? and pic_url.match(/^http:/)
      pic_url.sub!(/^http:/, 'https:')
    end
    pic_url
  end
  
  def entity_profile_url(entity)
    domain = if Rails.env.production? or Rails.env.staging?
      "http://#{ENV['SERVER']}.soletron.com" 
    elsif Rails.env.development?
      'http://shop.soletron.dev:3000'
    end
    entity_profile_path(entity, :domain => domain)
  end
  
  # This is also used in the model Follow, so that host has to be explicit
  def entity_profile_path(entity, opts={})
    case entity
    when Spree::User
      (opts[:domain] ? opts[:domain] : '') + main_app.member_path(entity)
    when Store
      (opts[:domain] ? opts[:domain] : '') + main_app.store_path(entity)
    else
      "#"
    end
  end
  
  def entity_profile_url(entity)
    domain = if Rails.env.production? or Rails.env.staging?
      "http://#{ENV['SERVER']}.soletron.com" 
    elsif Rails.env.development?
      'http://shop.soletron.dev:3000'
    end
    entity_profile_path(entity, :domain => domain)
  end
  
  def stop_following_entity_path(entity)
    case entity
    when Spree::User
      main_app.member_follow_path(entity)
    when Store
      main_app.store_follow_path(entity)
    else
      "#"
    end
  end
  
  def follow_entity_path(entity)
    case entity
    when Spree::User
      main_app.member_follow_path(entity)
    when Store
      main_app.store_follow_path(entity)
    else
      "#"
    end
  end

  def entity_feed_url(entity, action=nil)
    request.protocol+if Rails.env.development?
      request.host_with_port
    else
      request.host
    end+entity_feed_path(entity, action=nil)
  end
  
  def entity_feed_path(entity, action=nil)
    case entity
    when Store
      case action
      when :all
        main_app.all_store_feed_path(entity)
      when :network
        main_app.network_store_feed_path(entity)
      when nil, :me
        main_app.store_feed_path(entity)
      else
        '#'
      end
    when Spree::User
      case action
      when :all
        main_app.all_member_feed_path(entity)
      when :network
        main_app.network_member_feed_path(entity)
      when nil, :me
        main_app.member_feed_path(entity)
      else
        '#'
      end
    else
      '#'
    end
  end
  
  def entity_shoutout_path(entity)
    case entity
    when Spree::User
      main_app.member_shoutout_path(entity)
    when Store
      main_app.store_shoutout_path(entity)
    else
      '#'
    end
  end
  
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
  
  def entity_followers_count(number)
    num = case number
    when Spree::User, Store
      number.followers.count
    when Fixnum
      number
    end
    if num.nil?
      num = 0
    end
    if num == 1
      "1 Follower"
    else
      "#{num} Followers"
    end
  end
  
  def user_pull_from_facebook?(attribute)
      pull_from_facebook?(@user.facebook_auth, attribute)
  end
  
  def pull_from_facebook?(auth, attribute)
    if auth
      content_tag(:span, :class => 'pull-from-facebook') do
        check_box_tag("from_facebook[#{attribute}]")+label_tag("from_facebook[#{attribute}]") do
          image_tag("/assets/social/facebook_32.png", :height => 15)+content_tag(:span, 'Pull from Facebook')
        end
      end
    end
  end
  
  def latest_products(entity, number, options={})
    case entity
    when Store
      if entity.taxon
        entity.taxon.products.order('created_at DESC').includes(:images).sort_by{rand}.slice(0,number)
      else
        []
      end
    when Spree::User
      if options[:type] == :favorite
        entity.product_search(:favorites, :per_page => 1000).sort_by{rand}.slice(0,number)
      else
        entity.product_search(:purchases, :per_page => 1000).sort_by{rand}.slice(0,number)
      end
    end
  end
  
  def link_to_followings(member)
    return main_app.following_store_path(member) if member.is_a?(Store) 
    return main_app.following_member_path(member)
  end
  
  def link_to_followers(member)
    return main_app.followers_store_path(member) if member.is_a?(Store) 
    return main_app.followers_member_path(member)
  end
end