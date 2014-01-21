class AddAmountToLineItemPromotionCredit < ActiveRecord::Migration
  def self.up
    change_table :line_item_promotion_credits do |t|
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0.0, :null => false
    end
  end

  def self.down
    change_table :line_item_promotion_credits do |t|
      t.remove :amount
    end
  end
end
