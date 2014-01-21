class Spree::UserMailer < ActionMailer::Base

  def items_creation_notifications(users,products,store)
    users_emails = []
    users.each do|user|
      users_emails << user.follower.email
    end
#    users = ["noumankhalid786@gmail.com","mahhek.khan@gmail.com"]
    users = users_emails
    
    @products = products
    @store = store
    mail(:to => users,
         :subject => "New items added at #{store}")
  end
    
  def update_on_less_items(user,products,store)
    @products = products
    @store = store
    mail(:to => user,
         :subject => "Items quantity is low at #{store}")
  end
  
  def reset_password_instructions(user)
    @edit_password_reset_url = edit_user_password_url(:reset_password_token => user.reset_password_token)
    mail(:to => user.email,
      :subject => Spree::Config[:site_name] + ' ' + I18n.t("password_reset_instructions"))
  end

  def confirmation_instructions(object, guest=false)
    if object.is_a?(Spree::Order)
      @email = if object.user.anonymous?
        object.email
      else
        object.user.email
      end
      @confirmation_token = object.user.confirmation_token
      @checking_out = true if object.user.anonymous?
    else
      @email = object.email
      @confirmation_token = object.confirmation_token
    end
    #@confirmation_link = main_app.checkout_confirmation_url(:confirmation_token => user.confirmation_token) 
    if @checking_out #user.anonymous? or user.login.include? "@example.net" or guest
      @confirmation_link = main_app.checkout_confirmation_url(:confirmation_token => @confirmation_token) 
      @template = 'registration_instructions'
    else
      @confirmation_link = main_app.confirmation_url(:confirmation_token => @confirmation_token) 
      @template = 'confirmation_instructions'
    end
    mail(:to => @email,
      :subject => 'Soletron validation of your email',
      :template_name => @template)
  end
end

