module ProfileImagesHelper
    
  def facebook_picture_url(facebook_id, size=:large)
    "https://graph.facebook.com/#{facebook_id}/picture?type=#{size}"
  end

end