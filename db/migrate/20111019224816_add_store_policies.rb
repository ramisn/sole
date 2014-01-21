class AddStorePolicies < ActiveRecord::Migration
  def self.up
	change_table :stores do |t|
		t.text :policies
		t.text :return_policies
		t.string :customer_support
	end
  end

  def self.down
    change_table :stores do |t|
      t.remove :policies
      t.remove :return_policies
	  t.remove :customer_support
    end  
  end
end
