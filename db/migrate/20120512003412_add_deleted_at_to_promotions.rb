class AddDeletedAtToPromotions < ActiveRecord::Migration
  def self.up
    change_table :promotions do |t|
      t.datetime :deleted_at
    end
  end

  def self.down
    change_table :promotions do |t|
      t.remove :deleted_at
    end
  end
end
