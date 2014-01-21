class AddNewColors < ActiveRecord::Migration
  def self.up
	if OptionValue.find_by_name("colorTeal").nil?
		ovTeal1 = OptionValue.create(:option_type_id => OptionType.find_by_name("color1").id,
								   :name => "colorTeal",
								   :presentation => "Teal")
		ovTeal1.save
		
		ovTeal2 = OptionValue.create(:option_type_id => OptionType.find_by_name("color2").id,
								   :name => "colorTeal",
								   :presentation => "Teal")
		ovTeal2.save		
	end
	
	if OptionValue.find_by_name("colorGlow").nil?
		ovGlow1 = OptionValue.create(:option_type_id => OptionType.find_by_name("color1").id,
								   :name => "colorGlow",
								   :presentation => "Glowing")
		ovGlow1.save
		
		ovGlow2 = OptionValue.create(:option_type_id => OptionType.find_by_name("color2").id,
								   :name => "colorGlow",
								   :presentation => "Glowing")
		ovGlow2.save
	end	
  end

  def self.down
  end
end
