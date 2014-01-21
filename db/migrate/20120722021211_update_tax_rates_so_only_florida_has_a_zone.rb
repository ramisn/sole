class UpdateTaxRatesSoOnlyFloridaHasAZone < ActiveRecord::Migration
  def up
    Spree::Calculator.update_all({:type => 'Spree::Calculator::DefaultTax'}, {:type => 'Spree::Calculator::SalesTax'})
    Spree::Calculator::DefaultTax.destroy_all
    Spree::TaxRate.destroy_all
    
    zone = Spree::Zone.find_by_name 'Florida'
    if zone.nil?
      zone = Spree::Zone.new :name => 'Florida', :description => 'Florida'
      zone.save!
    end
    if zone.zone_members.count > 1
      Spree::ZoneMember.delete_all :id => zone.zone_members.to_a.reject {|zm| zm.zoneable.abbr == 'FL'}
      zone.zone_members.reload
    end
    if zone.zone_members.count == 0
      zone_member = Spree::ZoneMember.new :zoneable => Spree::State.find_by_abbr('FL'), :zone => zone
      zone.zone_members << zone_member
    end
    tax_category = Spree::TaxCategory.find_by_name('Clothing')
    florida_tax = Spree::Calculator::DefaultTax.new 
    tax_rate = Spree::TaxRate.new :amount => 6.0, :tax_category => tax_category, :zone => zone, :calculator => florida_tax
    tax_rate.save!
  end

  def down
  end
end
