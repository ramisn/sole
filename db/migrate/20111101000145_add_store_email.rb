class AddStoreEmail < ActiveRecord::Migration
  def self.up
	change_table :stores do |t|
		t.string :customer_support_phone
	end
  end

  def self.down
    change_table :stores do |t|
	  t.remove :customer_support_phone
    end
  end
end
