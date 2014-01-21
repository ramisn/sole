class FixSizes < ActiveRecord::Migration
  def self.up
	ov = OptionValue.find_by_name("sizehatXXL")
	if !ov.nil?
		ov.presentation = "2XL"
		ov.save
	end
	
	ov = OptionValue.find_by_name("sizehatXXXL")
	if !ov.nil?
		ov.presentation = "3XL"
		ov.save
	end
	
	ov812 = OptionValue.find_by_name("sizehat812")
	ov838 = OptionValue.create(:option_type_id => OptionType.find_by_name("hats-size").id,
							   :name => "sizehat838",
							   :presentation => "8 3/8")
	ov838.position = ov812.position
	ov838.save
	sizes = ["sizehat812", "sizehatS", "sizehatM", "sizehatL", "sizehatXL", "sizehatXXL", "sizehatXXXL"]
	sizes.each do |hat_size|
		ov = OptionValue.find_by_name(hat_size)
		ov.position = ov.position + 1
		ov.save
	end
  end

  def self.down
  end
end
