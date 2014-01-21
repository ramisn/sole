class Spree::OrderMailer < ActionMailer::Base
  helper "spree/base"

  def confirm_email(order, resend=false)
    @order = order
    subject = (resend ? "[RESEND] " : "")
    subject += "Your Soletron Order - #{order.number}"
    mail(:to => order.email,
         :subject => subject)
  end

  def confirm_sale(order, items, email, store, resend=false)
    @order = order
    @items = items
    @store = store
    subject = (resend ? "[RESEND] " : "")
    subject += "URGENT: You Just Made A Sale On Soletron - #{order.number}"
    mail(:to => email,
         :subject => subject)
  end

  def cancel_email(order, resend=false)
    @order = if order.is_a?(OrdersStore)
      order.order
    else
      order
    end
    subject = (resend ? "[RESEND] " : "")
    subject += "#{Spree::Config[:site_name]} #{t('subject', :scope => 'order_mailer.cancel_email')} ##{order.number}"
    mail(:to => order.email,
         :subject => subject)
  end

  def cancel_item_email(order, resend=false)
    @order = order
    subject = (resend ? "[RESEND] " : "")
    subject += "#{Spree::Config[:site_name]} #{t('subject', :scope => 'order_mailer.cancel_email')} ##{order.number}"
    mail(:to => order.email,
         :subject => subject)
  end

  def cancel_unit_email(order, variant, resend=false)
    @order = order
    @variant = variant
    subject = (resend ? "[RESEND] " : "")
    subject += "#{Spree::Config[:site_name]} #{t('subject', :scope => 'order_mailer.cancel_email')} ##{order.number}"
    mail(:to => order.email,
         :subject => subject)
  end
end
