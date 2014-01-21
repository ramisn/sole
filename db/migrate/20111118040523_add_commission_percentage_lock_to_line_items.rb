class AddCommissionPercentageLockToLineItems < ActiveRecord::Migration
  def self.up
    change_table :line_items do |t|
      t.boolean :commission_percentage_lock
    end
  end

  def self.down
    change_table :line_items do |t|
      t.remove :commission_percentage_lock
    end
  end
end
