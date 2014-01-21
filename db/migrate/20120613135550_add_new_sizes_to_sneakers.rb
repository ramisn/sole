class AddNewSizesToSneakers < ActiveRecord::Migration
  def self.up
    taxon1 = Taxon.find(:first, :conditions => ["name #{LIKE} ?", "%sneaker%"])
    products1 = taxon1.products
    
    taxon2 = Taxon.find(:first, :conditions => ["name #{LIKE} ?", "%custom sneaker%"])
    products2 = taxon2.products
    
    val = OptionValue.find(:first, :conditions => ["name #{LIKE} ?", "%sizeshoe%"])
    opt_id = val.option_type_id
    opt1 = OptionValue.new(:option_type_id => opt_id, :name => "sizeshoeUS3", :position => 1, :presentation => "3")
    opt1.save
    
    opt2 = OptionValue.new(:option_type_id => opt_id, :name => "sizeshoeUS35", :position => 2, :presentation => "3.5")
    opt2.save
    
    opt3 = OptionValue.new(:option_type_id => opt_id, :name => "sizeshoeUS4", :position => 3, :presentation => "4")
    opt3.save
    
    opt4 = OptionValue.new(:option_type_id => opt_id, :name => "sizeshoeUS45", :position => 4, :presentation => "4.5")
    opt4.save
    
    opt5 = OptionValue.new(:option_type_id => opt_id, :name => "sizeshoeUS5", :position => 5, :presentation => "5")
    opt5.save
    
    opt6 = OptionValue.new(:option_type_id => opt_id, :name => "sizeshoeUS55", :position => 6, :presentation => "5.5")
    opt6.save
    
    
    products1.each do|prod|          
      variants = prod.variants
      unless variants.blank?
        variants.each do|var|
          var.option_values << opt1
          var.option_values << opt2
          var.option_values << opt3
          var.option_values << opt4
          var.option_values << opt5
          var.option_values << opt6
        end
      end
    end
    
    products2.each do|prod|          
      variants = prod.variants
      unless variants.blank?
        variants.each do|var|
          var.option_values << opt1
          var.option_values << opt2
          var.option_values << opt3
          var.option_values << opt4
          var.option_values << opt5
          var.option_values << opt6
        end
      end
    end
    
  end

  def self.down
  end
end
