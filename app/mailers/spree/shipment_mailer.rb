class Spree::ShipmentMailer < ActionMailer::Base
  helper "spree/base"

  def shipped_email(shipment, resend=false)
    @shipment = shipment
    @order = shipment.order
    subject = (resend ? "[RESEND] " : "")
    subject += "#{Spree::Config[:site_name]} #{t('subject', :scope => 'shipment_mailer.shipped_email')} ##{shipment.order.number}"
    mail(:to => shipment.order.email,
         :subject => subject)
  end
end
