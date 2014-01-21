class AddStateToStore < ActiveRecord::Migration
  def change
    add_column :stores, :state, :string, :limit => 50
  end
end
