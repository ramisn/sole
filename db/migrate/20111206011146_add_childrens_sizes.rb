class AddChildrensSizes < ActiveRecord::Migration
  def self.up

    sizes = [{:name => "sizetopK23T", :presentation => "Kids 2/3T"},
             {:name => "sizetopK45T", :presentation => "Kids 4/5T"},
             {:name => "sizetopK67",  :presentation => "Kids 6/7"}]

    tops_id = OptionType.find_by_name("tops-size").id
    sizes.each do |child_size|
      ov = OptionValue.find_by_name(child_size[:name])
      if ov.nil?
        ov = OptionValue.create(:option_type_id => tops_id,
                       :name => child_size[:name],
                       :presentation => child_size[:presentation])
        ov.save
      end
    end

    ovAll = OptionValue.find_by_name("sizehatkidsAll")
    if ovAll.nil?
      ovAll = OptionValue.create(:option_type_id => OptionType.find_by_name("hats-size").id,
                     :name => "sizehatkidsAll",
                     :presentation => "Kids - Fits All")
      success = ovAll.save
  end

  def self.down
    sizes = ["sizetopK23T", "sizetopK45T", "sizetopK67", "sizehatkidsAll"]
    sizes.each do |child_size|
      ov = OptionValue.find_by_name(child_size)
      OptionValue.delete(ov) unless ov.nil?
    end
  end
  end
end