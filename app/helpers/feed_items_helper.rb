module FeedItemsHelper
  def has_consolidated_items?(feed_item)
    feed_item.consolidated_items and feed_item.consolidated_items.size > 0  
  end
  
  def favorite_feed_item_title(feed_item)
    content_tag(:span, raw("just added #{link_to(feed_item.feedable.product.name, feed_item.feedable.product)}#{
      if feed_item.consolidated_feed_items.count == 1
        " and 1 other item"
      elsif feed_item.consolidated_feed_items.count > 1
        " and #{feed_item.consolidated_feed_items.count} other items"
      end
      } as a favorite item"))
  end
  
  def product_feed_item_title(feed_item)
    content_tag(:span, raw("just added #{feed_item.feedable.is_a?(UserProduct) ? link_to(feed_item.feedable.name, uploaded_member_collection_path(feed_item.feedable.user)) : link_to(feed_item.feedable.name, feed_item.feedable)}#{
      if feed_item.consolidated_feed_items.count == 1
        " and 1 other item"
      elsif feed_item.consolidated_feed_items.count > 1
        " and #{feed_item.consolidated_feed_items.count} other items"
      end
      } to their #{feed_item.feedable.is_a?(UserProduct) ? 'collection' : 'store'}"))
  end
  
  def comment_on_profile(feed_item)
    item = feed_item.feedable.feed_item.feedable
    entity_link = case item
    when Favorite
      item.user
    when Shoutout
      item.posted_to
    when Spree::Order
      item.user
    when UserProduct
      item.user
    when Product
      item.store
    when Follow
      feed_item.feedable.feed_item.displayable
    end
    
    if entity_link
      link_to entity_link.display_name, entity_profile_path(entity_link)
    end
  end
  
  def feed_item_data(feed_item)
    item_data = {}
    item_data[:can_delete] = (@acting_as == feed_item.displayable or (feed_item.feedable.is_a?(Shoutout) and feed_item.feedable.poster == @acting_as))
    item_data[:line_item] = false
    
    case feed_item.feedable
    when Follow
      item_data[:entity_to_display] = feed_item.feedable.follower
      item_data[:data_to_display] = render(:partial => 'feed_items/follow', :locals => {:feed_item => feed_item})
    when Shoutout
      item_data[:entity_to_display] = feed_item.feedable.poster
      item_data[:data_to_display] = render(:partial => 'feed_items/shoutout', :locals => {:feed_item => feed_item})
      if !item_data[:can_delete]
        item_data[:can_delete] = (feed_item.feedable.poster == @acting_as)
      end
    when Comment
      item_data[:entity_to_display] = feed_item.feedable.commenter
      item_data[:data_to_display] = render(:partial => 'feed_items/comment', :locals => {:feed_item => feed_item})
      item_data[:line_item] = true
    when Spree::Order
	  item_data[:entity_to_display] = feed_item.feedable.user
	  item_data[:data_to_display] = render(:partial => 'feed_items/order', :locals => {:feed_item => feed_item})
    when UserProduct
	  if !feed_item.feedable.nil?
		  item_data[:entity_to_display] = feed_item.feedable.user
		  item_data[:data_to_display] = render(:partial => 'feed_items/user_product', :locals => {:feed_item => feed_item})
	  end
    when Spree::Product
	  if !feed_item.feedable.nil?
		  item_data[:entity_to_display] = feed_item.feedable.taxons.where("spree_taxons.store_id IS NOT NULL").first.store
		  item_data[:data_to_display] = render(:partial => 'feed_items/product', :locals => {:feed_item => feed_item})
	  end
    when Favorite
	  if !feed_item.feedable.product.nil?
		  item_data[:entity_to_display] = feed_item.feedable.user
		  item_data[:data_to_display] = render(:partial => 'feed_items/favorite', :locals => {:feed_item => feed_item})
	  end
    end
    item_data
  end
end
