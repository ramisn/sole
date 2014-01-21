FactoryGirl.define do
  factory :inventory_unit, class: Spree::InventoryUnit do
    line_item do
      Spree::Config.temp_set(allow_backorders: true, allow_backorder_shipping: true) {
        FactoryGirl.create(:open_line_item)
      }
    end
    #variant { FactoryGirl.create(:variant) }
    #order { FactoryGirl.create(:order) }
    state 'sold'
    
    shipment { FactoryGirl.create(:shipment, :pending) }
    #return_authorization { FactoryGirl.create(:return_authorization) }
    
    trait :one_item do
      line_item do
        Spree::Config.temp_set(allow_backorders: true, allow_backorder_shipping: true) {
          FactoryGirl.create(:open_line_item, :quantity => 1)
        }
      end
    end
    
    trait :multi do
      line_item do
        Spree::Config.temp_set(allow_backorders: true, allow_backorder_shipping: true) {
          FactoryGirl.create(:open_line_item, :quantity => 3)
        }
      end
    end
    
    trait :shipped do
      state 'shipped'
      shipment { FactoryGirl.create(:shipped_shipment) }
    end
    
    trait :canceled do
      state 'canceled'
      shipment { FactoryGirl.create(:shipment, :state => 'canceled') }
    end
    
    trait :shipped_late do
      state 'shipped'
      shipment { FactoryGirl.create(:late_shipped_shipment)}
    end
    
    factory :solo_inventory_unit, :traits => [:one_item]
    factory :multi_inventory_unit, :traits => [:multi]
    factory :shipped_inventory_unit, :traits => [:shipped]
    factory :shipped_sole_inventory_unit, :traits => [:one_item, :shipped]
    factory :canceled_inventory_unit, :traits => [:canceled]
    factory :shipped_late_inventory_unit, :traits => [:late]
    
    
    after(:create) do |inventory_unit|
      #puts "iu proxy is #{proxy}"
      #inventory_unit.line_item.inventory_units = [inventory_unit]
      order = inventory_unit.line_item.order
      order.line_items.reload
      inventory_unit.order = order
      order.inventory_units.reload
      inventory_unit.shipment.order = order
      order.shipments.reload
      #puts "shipment is #{inventory_unit.shipment.inspect}"
      inventory_unit.shipment.inventory_units.reload
      #inventory_unit.shipment.inventory_units.each do |iu|
      #  puts "shipment iu is #{iu.inspect}"
      #  if iu.variant.nil?
      #    puts " deleting!"
      #    iu.destroy
      #    inventory_unit.shipment.inventory_units.delete(iu)
      #  end
      #end
      #inventory_unit.shipment.inventory_units = [inventory_unit]
      inventory_unit.shipment.save!
      inventory_unit.order.ensure_all_orders_stores
      inventory_unit.order.open_orders_stores
      inventory_unit.order.update!
      inventory_unit.order.payments << FactoryGirl.create(:payment, :state => 'completed', :amount => inventory_unit.order.total, :order => inventory_unit.order)
      inventory_unit.order.update!
      inventory_unit.order.payments.first.update_attribute_without_callbacks :amount, inventory_unit.order.total
      inventory_unit.variant = inventory_unit.line_item.variant
      if inventory_unit.variant.product.nil?
        inventory_unit.variant.update_attributes(:product_id => FactoryGirl.create(:product))
      end
      if inventory_unit.variant.product.store.nil?
        inventory_unit.variant.product.store = FactoryGirl.create(:store_without_taxon)
      end
      inventory_unit.save!
    end
  end
end

def Factory.custom_inventory_unit(type, options)
  inventory_unit = FactoryGirl.create(type)
  if options[:store]
    product = inventory_unit.variant.product
    product.taxons.where('spree_taxons.store_id IS NOT NULL').each {|taxon| product.taxons.destroy(taxon)}
    product.taxons << options[:store].taxon
    #existing_taxon = inventory_unit.variant.product.taxons.where('taxons.store_id IS NOT NULL')[0]
    #inventory_unit.variant.product.taxons.delete(existing_taxon)
    #inventory_unit.variant.product.taxons << FactoryGirl.create(:store_taxon, :store => options[:store])
  end
  if type == :solo_inventory_unit or type == :shipped_sole_inventory_unit
    inventory_unit.order.line_items.where('spree_line_items.id != ?', inventory_unit.line_item).destroy_all
    inventory_unit.order.inventory_units.where('spree_inventory_units.id != ?', inventory_unit).destroy_all
    inventory_unit.shipment.inventory_units.where('spree_inventory_units.id != ?', inventory_unit).destroy_all
    inventory_unit.order.shipments.where('spree_shipments.id != ?', inventory_unit.shipment).destroy_all
  end
  inventory_unit
end
