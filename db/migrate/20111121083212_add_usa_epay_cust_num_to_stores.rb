class AddUsaEpayCustNumToStores < ActiveRecord::Migration
  def self.up
    change_table :stores do |t|
      t.integer :usa_epay_customer_number
    end
  end

  def self.down
    change_table :stores do |t|
      t.remove :usa_epay_customer_number
    end
  end
end
