class LockRelevantCommissionPercentages < ActiveRecord::Migration
  def self.up
    LineItem.joins(:order).where(:orders => {:state => [:canceled, :complete]}, :commission_percentage_lock => false).update_all(:commission_percentage_lock => true)
  end

  def self.down
  end
end
