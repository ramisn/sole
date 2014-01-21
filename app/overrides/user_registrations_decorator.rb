# From spree_social

Deface::Override.new(:virtual_path => "/spree/user_registrations/new",
                     :name => "add_social_links_to_login_extras",
                     :insert_after => "div#new-customer",#"[data-hook='login_extras']",
                     :partial => "/spree/shared/socials",
                     :disabled => false)

Deface::Override.new(:virtual_path => "/spree/user_registrations/new",
                     :name => "add_omni_auth_to_signup_inside_form",
                     :replace => "[data-hook='signup_inside_form']",
                     :partial => "/spree/user_registrations/omni_auth_form",
                     :disabled => false)


Deface::Override.new(:virtual_path => "/spree/user_registrations/new",
                     :name => "add_replace_login_as_existing_link",
                     :replace => "code[erb-loud]:contains('login_as_existing')",
                     :text => %q{<%= session[:omniauth] ? link_to( t("login_as_existing"), spree.user_registration_path, :method => :delete) : link_to( t("login_as_existing"), spree.login_path) %>},
                     :disabled => false)