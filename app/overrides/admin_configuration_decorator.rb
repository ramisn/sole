# From spree_social

Deface::Override.new(:virtual_path => "admin/shared/_configuration_menu",
                     :name => "add_social_providers_link_to_configuration_menu",
                     #:insert_after => "ul.sidebar code[erb-loud]:contains('hook :admin_configurations_sidebar_menu')",
                     :insert_bottom => "ul.sidebar",#"[data-hook='admin_configurations_sidebar_menu']",
                     :text => %q{<li<%== ' class="active"' if controller.controller_name == 'authentication_methods' %>><%= link_to "Social Network Providers", admin_authentication_methods_path %></li>},
                     #:text => %q{<%= configurations_sidebar_menu_item t("social_servers"), admin_authentication_methods_path %>},
                     :disabled => false)

Deface::Override.new(:virtual_path => "admin/configurations/index",
                     :name => "add_social_provider_row_to_configuration_menu",
                     :insert_bottom => "table.index tbody",
                     #:insert_after => "[data-hook='admin_configurations_menu']",
                     :partial => "admin/shared/configurations_menu",
                     :disabled => false)
