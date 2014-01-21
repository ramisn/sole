class AddingResponseDataToVendorPayments < ActiveRecord::Migration
  def self.up
    change_table :payments do |t|
      t.text :response_data
    end
  end

  def self.down
    change_table :payments do |t|
      t.remove :response_data
    end
  end
end
