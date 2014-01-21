class AddAndChangeColumnsInOrdersStoresForCommissions < ActiveRecord::Migration
  def self.up
    change_table :orders_stores do |t|
      t.rename :store_cut, :product_reimbursement
      t.decimal :total_reimbursement, :precision => 8, :scale => 2, :default => 0.0, :null => false
    end
  end

  def self.down
    change_table :orders_stores do |t|
      t.rename :product_reimbursement, :store_cut
      t.remove :total_reimbursement
    end
  end
end
