class CreateLineItemPromotionCredits < ActiveRecord::Migration
  def self.up
    create_table :line_item_promotion_credits do |t|
      t.references :line_item
      t.references :promotion_credit
      t.integer :quantity
      
      t.timestamps
    end
  end

  def self.down
    drop_table :line_item_promotion_credits
  end
end
