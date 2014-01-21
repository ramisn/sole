# From spree_social

Deface::Override.new(:virtual_path => "/spree/user_sessions/new",
                     :name => "add_social_links_to_login_extras",
                     :insert_after => "div#existing-customer",#"[data-hook='login_extras']",
                     :partial => "/shared/socials",
                     :disabled => false)

Deface::Override.new(:virtual_path => "/spree/user_sessions/new",
                     :name => "squash_alert_flash_message",
                     :remove => "code[erb-loud]:contains('flash[:alert]')",
                     :disabled => false)

#Deface::Override.new(:virtual_path => "user_sessions/new",
#                     :name => "add_flash_messages_to_login_page",
#                     :insert_before => "div#existing-customer",
#                     :partial => "shared/flash_messages",
#                     :disabled => false)

