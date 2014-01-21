module FeedsHelper
    
  def feed_comments_count(number)
    num = if number.is_a?(FeedItem)
      if number.feedable.is_a?(Shoutout)
        number.self_and_sibling_comments.count
      else
        number.comments.count
      end
    elsif number.is_a?(Fixnum)
      number
    end
    if num.nil?
      num = 0
    end
    if num == 1
      "1 Comment"
    else
      "#{num} Comments"
    end
  end
  
  def feed_type_display(feed_item)
    case feed_item.feedable
    when Comment
      "a comment"
    when Shoutout
      "a shoutout"
    when Follow
      "a follow"
    when Favorite
      "a favorite"
    when Product
      "a posted product"
    when Spree::Order
      "a purchase"
    else
      puts "do not have feed type display for #{feed_item.feedable.class}"
    end
  end
  
  def entity_atom_feed_path(entity)
    case entity
    when Spree::Taxon #Store
      main_app.store_feed_path(entity)+'/feed.atom'
    when Spree::User
      main_app.member_feed_path(entity)+'/feed.atom'
    end
  end

  def get_display_name(object)
    if object.class.name == "Store"
      name = object.name_from_taxon
      if !name.nil? && !name.empty?
        name = name + "'s"
      end
      name
    elsif object.class.name == "Spree::User"
      name = object.display_name
      if !name.nil? && !name.empty?
        name = name + "'s"
      end
    else
      ""
    end
  end
  
end