Deface::Override.new(:virtual_path => "layouts/admin",
                       :name => "add_stores_menu_item",
                       :insert_after => "code[erb-loud]:contains('admin/shared/tabs')",
                       :partial => "admin/shared/more_tabs",
                       :disabled => false)

Deface::Override.new(:virtual_path => "admin/shared/_product_sub_menu",
                      :name => "add_store_admin_menu_items",
                      :insert_top => "ul#sub_nav",
                      :partial => "admin/shared/added_storefront_nav",
                      :disabled => false)

Deface::Override.new(:virtual_path => "layouts/admin",
                      :name => "add_soletron_css",
                      :insert_after => "code[erb-loud]:contains('shared/admin_head')",
                      :partial => "admin/shared/css",
                      :disabled => false)

Deface::Override.new(:virtual_path => 'layouts/admin',
                      :name => 'add_facebook_pages_login_popup_to_head',
                      :insert_after => "code[erb-loud]:contains('shared/admin_head')",
                      :partial => '/shared/login_popup',
                      :disabled => false)

#Deface::Override.new(:virtual_path => 'layouts/admin',
#                      :name => 'add_check_for_store_facebook_link',
#                      :insert_after => "div#sub-menu",
#                      :partial => "merchant/shared/store_facebook_alert",
#                      :disabled => false)

#Deface::Override.new(:virtual_path => 'layouts/admin',
#                      :name => 'add_check_for_store_facebook_link',
#                      :insert_top => "div#template-container",
#                      :partial => "merchant/shared/store_facebook_alert",
#                      :disabled => false)
