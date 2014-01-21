class AddFitsAllHatSize < ActiveRecord::Migration
  def self.up
	ovAll = OptionValue.find_by_name("sizehatAll")
	if ovAll.nil?
		ovAll = OptionValue.create(:option_type_id => OptionType.find_by_name("hats-size").id,
								   :name => "sizehatAll",
								   :presentation => "Fits All")
		success = ovAll.save
	else
		success = true
	end
	
	if success
		Taxon.find_by_name("Snapback").products.each do |snapback|
			puts "found a snapback hat: #{snapback.name}"
			if snapback.variants.size == 1
				size = snapback.variants[0].option_values.find_by_option_type_id(OptionType.find_by_name("hats-size").id)
				unless size.nil?
					puts "deleting size #{size.presentation}"
					snapback.variants[0].option_values.delete(size)
				end
				snapback.variants[0].option_values << ovAll
				snapback.variants[0].save
				snapback.save
			end
			puts "done with #{snapback.name}"
		end
	end
  end

  def self.down
  end
end
