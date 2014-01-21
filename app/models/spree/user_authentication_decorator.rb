Spree::UserAuthentication.class_eval do
  
  def self.users_from_facebook_ids(facebook_ids)
    self.includes(:user).where(:uid => facebook_ids).inject([]) do |array, auth|
      array << auth.user
      array
    end
  end

end