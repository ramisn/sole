namespace :products do

  task :populate_bracelet_sizes => [:environment] do
    import_data = [
        OpenStruct.new({ name: "sizeS-7.5''", presentation: "S-7.5''" }),
        OpenStruct.new({ name: "sizeM-8.5''", presentation: "M-8.5''" })
    ]
    option_type =
        if Spree.version > "1.0"
          Spree::OptionType.find_by_name!('jewelry-size')
        else
          OptionType.find_by_name!('jewelry-size')
        end
    import_data.each do |data|
      option_type.option_values.create! name: data.name, presentation: data.presentation
    end
  end

end