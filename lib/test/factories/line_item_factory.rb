FactoryGirl.define do
  factory :line_item, class: Spree::LineItem do
    # quantity and product modified
    quantity { rand(5)+1 }
    price { BigDecimal.new((rand(100)+1).to_s) }

    # associations:
    order { FactoryGirl.build(:order)}
    store { FactoryGirl.build(:store)}
    variant {FactoryGirl.build(:variant)}#association(:variant)#, :product => FactoryGirl.create(:product, :store => self.store)) }
    #association(:variant, :factory => :variant)
    
    trait :ready do
      state 'open'
      order { FactoryGirl.build(:complete_not_shipped_order) }
    end
    
    trait :shipped do
      state 'closed'
      order { FactoryGirl.build(:complete_shipped_order) }
    end
    
    trait :canceled do
      state 'canceled'
    end
    
    trait :closed_late do
      state 'closed_late'
      order { FactoryGirl.build(:late_shipped_order) }
    end
    
    trait :promotion_credits do
      after(:build) do |line_item|
        line_item.line_item_promotion_credits << FactoryGirl.create(:line_item_promotion_credit, line_item: line_item)
        line_item.line_item_promotion_credits << FactoryGirl.build(:free_shipping_line_item_promotion_credit, line_item: line_item)
      end
      quantity 4
    end
    
    trait :on_sale do
      variant { FactoryGirl.create(:on_sale_variant) }
      on_sale true
    end
    
    factory :open_line_item, :traits => [:ready]
    factory :shipped_line_item, :traits => [:shipped]
    factory :canceled_line_item, :traits => [:canceled]
    factory :closed_late_line_item, :traits => [:closed_late]
    factory :line_item_with_promotion_credits, :traits => [:promotion_credits, :ready]
    factory :on_sale_line_item, :traits => [:on_sale, :ready]
    
    after(:create) do |line_item, proxy|
      Spree::Config.temp_set(allow_backorders: true, allow_backorder_shipping: true) {
        line_item.order.save
        #puts "proxy is #{proxy}"
        if line_item.open?
          line_item.quantity.times do
            line_item.inventory_units << FactoryGirl.create(:inventory_unit, :line_item => line_item)
          end
          line_item.save
        elsif line_item.closed?
          line_item.quantity.times do
            line_item.inventory_units << FactoryGirl.create(:shipped_inventory_unit, :line_item => line_item)
          end
          line_item.save
        elsif line_item.closed_late?
          line_item.quantity.times do
            line_item.inventory_units << FactoryGirl.create(:shipped_inventory_unit, :line_item => line_item)
          end
          line_item.save
        elsif line_item.canceled?
          line_item.quantity.times do
            line_item.inventory_units << FactoryGirl.create(:canceled_inventory_unit, :line_item => line_item)
          end
          line_item.save
        end

        if line_item.line_item_promotion_credits.size > 0
          line_item.line_item_promotion_credits.each do |pc|
            #puts pc.inspect
            #puts pc.promotion_credit.inspect
            pc.line_item = line_item
            pc.save
          end
          line_item.line_item_promotion_credits.reload
        end
      }
    end
  end
end
