module FeedbackHelper
  def star_feedback_rating(rating)
    if rating.nil?
      rating = 5
    end
    whole = rating.to_i
    fraction = rating*100%100
    
    stars = []
    
    # add the whole numbers
    whole.times do |i|
      stars << 1
    end
    
    if stars.length < 5
      if fraction < 25
        # too small for half
        stars << 0
      elsif fraction < 75
        # halfway
        stars << 0.5
      else
        # roundup
        stars << 1
      end
      
      # fill in zeros
      (5-stars.length).times do |i|
        stars << 0
      end
    end
    
    content_tag(:span) do
      stars.collect do |item|
        url = case item
        when 1
          '/assets/star-whole.gif'
        when 0.5
          '/assets/star-half.gif'
        when 0
          '/assets/star-empty.gif'
        end
        concat(image_tag(url, :class => 'star-rating'))
      end
    end
  end
  
  def entity_feedback_path(parent, page, url_options={})
    link = if parent.is_a?(Spree::User)
      if page == :needed and current_user == parent
        needed_member_feedbacks_path(parent, url_options)
      elsif page == :done
        main_app.member_feedbacks_path(parent, url_options)
      end
    elsif parent.is_a?(Store)
      if page == :needed and current_user and current_user.stores_users.find_by_store_id(parent)
        needed_store_feedbacks_path(parent, url_options)
      elsif page == :done
        main_app.store_feedbacks_path(parent, url_options)
      end
    end
  end
  
  def entity_feedback_link(parent, page, url_options={}, color="FFF")
    name = if parent.is_a?(Spree::User)
      if page == :needed and current_user == parent
        "Awaiting Feedback"
      elsif page == :done
        "Feedback Left"
      end
    elsif parent.is_a?(Store)
      if page == :needed and current_user and current_user.stores_users.find_by_store_id(parent)
        "Awaiting feedback"
      elsif page == :done
        "Feedback"
      end
    end
    
    if name
      link_to name, entity_feedback_path(parent, page, url_options), :class => "profile-feed-link #{@selected == page ? 'selected' : ''}", :style => "color:##{color}; width: 150px;"
    end
  end
end
