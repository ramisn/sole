class AddIndexesForLineItemPromotionCredits < ActiveRecord::Migration
  def self.up
    add_index :line_item_promotion_credits, :line_item_id
    add_index :line_item_promotion_credits, :promotion_credit_id
  end

  def self.down
    remove_index :line_item_promotion_credits, :line_item_id
    remove_index :line_item_promotion_credits, :promotion_credit_id
  end
end
