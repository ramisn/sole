class Product < Spree::Product
  # WARNING: DO NOT TOUCH.
  # Spree migrated away from "Product" to "Spree::Product"
  # Under the hood this went from the `products` table to the `spree_products` table.
  # All of the current custom code uses "Product" and there's a lot of it.
  # So we'll just inherit from Spree::Product (for its methods)
  # And tell it to use the spree_products table. Also, disable STI.
  # This is a temporary "fallback" in case the migration misses any references and Q/A doesn't catch them either.
  # If you must edit Spree::Product behavior, use the decorator for
  # Spree::Product. Don't put more code in here.
  set_table_name 'spree_products'
  self.inheritance_column = :inheritence_disabled
end