class AddSalesToVariants < ActiveRecord::Migration
  def self.up
    add_column :variants, :sale_start_at, :datetime
    add_column :variants, :sale_end_at, :datetime
  end

  def self.down
    remove_column :variants, :sale_end_at
    remove_column :variants, :sale_start_at
  end
end