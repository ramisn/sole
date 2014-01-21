class AddSizesToJewelry < ActiveRecord::Migration
  def self.up
    taxon = Taxon.find(:first, :conditions => ["name = 'jewelry'"])
    
    unless taxon.blank?
      products = taxon.products
      unless products.blank?
        option_type = OptionType.new("name" => "jewelry-size","presentation" => 'Size')
        if option_type.save
          opt_id = option_type.id
          opt1 = OptionValue.new(:option_type_id => opt_id, :name => "sizeS-7''", :position => 1, :presentation => "S-7''")
          if opt1.save
            opt1 = opt1
          end
          opt2 = OptionValue.new(:option_type_id => opt_id, :name => "sizeM-8''", :position => 2, :presentation => "M-8''")
          if opt2.save
            opt2 = opt2
          end
          opt3 = OptionValue.new(:option_type_id => opt_id, :name => "sizeL-9''", :position => 3, :presentation => "L-9''")
          if opt3.save
            opt3 = opt3
          end
          opt4 = OptionValue.new(:option_type_id => opt_id, :name => "sizeFitsAll", :position => 4, :presentation => "FitsAll")
          if opt4.save
            opt4 = opt4
          end
        end
        products.each do|prod|          
          variants = prod.variants
          unless variants.blank?
            variants.each do|var|
              var.option_values << opt1
              var.option_values << opt2
              var.option_values << opt3
              var.option_values << opt4
            end
          end
        end
        
      end
    end
  end

  def self.down
  end
end
