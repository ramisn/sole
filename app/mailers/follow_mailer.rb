class FollowMailer < ActionMailer::Base
  helper "spree/base"
  helper "profiles"
  
  def user_followed(follow, resend=false)
    @follow = follow
    @user = @follow.following
    @follower = @follow.follower
    subject = (resend ? "[RESEND] " : "")
    subject += "#{Spree::Config[:site_name]} #{t('subject', :scope => 'follow_mailer.user_followed')} #{@follower.display_name}"
    mail(:to => @user.email,
         :subject => subject)
  end
  
  def store_followed(follow, manager, resend=false)
    @follow = follow
    @user = manager
    @store = @follow.following
    @follower = @follow.follower
    subject = (resend ? "[RESEND] " : "")
    subject += "#{Spree::Config[:site_name]} #{t('subject', :scope => 'follow_mailer.store_followed')} #{@follower.display_name}"
    mail(:to => @user.email,
         :subject => subject)
  end
end
