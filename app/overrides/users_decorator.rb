# From spree_social

Deface::Override.new(:virtual_path => "/spree/users/show",
                     :name => "put_social_logins_after_title",
                     #:insert_after => "h1",
                     :insert_after => "code[erb-loud]:contains('hook :account_summary')",
                     #:replace => "[data-hook='account_summary']",
                     :partial => "users/social",
                     :disabled => false)

Deface::Override.new(:virtual_path => "/spree/users/show",
                     :name => "remove_social_logins_email",
                     :replace => "div#existing-customer table",
                     :text => "",
                     :disabled => false)


