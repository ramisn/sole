class Merchant::VariantsController < Spree::Admin::VariantsController
  before_filter :authorized_store_member?
  before_filter :product_belongs_to_store?

  create.before :create_before
  update.before :create_before
end
