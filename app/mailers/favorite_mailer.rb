class FavoriteMailer < ActionMailer::Base
  helper "spree/base"
  helper "profiles"

  def product_favorited(favorite, manager, resend=false)
    @favorite = favorite
    @product = @favorite.product
    @user = manager
    @favoriter = @favorite.user
    @store = @product.master.product.store
    subject = (resend ? "[RESEND] " : "")
    subject += "#{Spree::Config[:site_name]} #{t('subject', :scope => 'favorite_mailer.product_favorited')} - #{@product.name}"
    mail(:to => manager.email,
         :subject => subject)
  end
end
