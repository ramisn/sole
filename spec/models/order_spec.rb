require 'spec_helper'

describe Spree::Order do
  
  context "shoulda validations" do
    it { should have_many(:line_items) }
    it { should have_many(:orders_stores) }
    #it { should have_many(:refunds) }
  end
  
  describe "#allow_cancel?" do
    
    it "should return true when all inventory units have been canceled" do
      @order = FactoryGirl.create(:complete_not_shipped_order)
      @order.stub!(:inventory_units).and_return([InventoryUnit.new(:state => 'canceled')])
      @order.allow_cancel?.should == true
    end
    
  end
  
  describe "#ensure_orders_store" do
    
    before :each do
      @order = FactoryGirl.create(:order)
    end
    
    it "should create an order store when none is present" do
      @order.orders_stores.size.should == 0
      
      # from "#line_items after_create", we know that this calls #ensure_orders_store
      line_item = FactoryGirl.build(:line_item, :order => @order)
      @order.ensure_orders_store(line_item.store)
      @order.orders_stores.size.should == 1
      
      added_orders_store = @order.orders_stores.first
      added_orders_store.store.should == line_item.store
      added_orders_store.order.should == @order
    end
    
    it "should not create an order store when that store is present" do
      line_item = FactoryGirl.create(:line_item, :order => @order)
      @order.orders_stores.size.should == 1
      
      # use the same store that is attached to the line_item that was added
      line_item_2 = FactoryGirl.build(:line_item, :order => @order, :store => line_item.store)
      
      @order.ensure_orders_store(line_item_2.store)
      @order.orders_stores.size.should == 1
      
      added_orders_store = @order.orders_stores.first
      added_orders_store.store.should == line_item.store
      added_orders_store.order.should == @order
    end
    
    it "should create a new order store when another store has already been linked to" do
      line_item = FactoryGirl.create(:line_item, :order => @order)
      @order.orders_stores.size.should == 1
      
      # have it generate a new store
      line_item_2 = FactoryGirl.build(:line_item, :order => @order)
      
      @order.ensure_orders_store(line_item_2.store)
      @order.orders_stores.size.should == 2
      
      added_orders_store = @order.orders_stores.find_by_store_id(line_item_2.store)
      added_orders_store.should_not be_nil
      added_orders_store.store.should == line_item_2.store
      added_orders_store.order.should == @order
    end
    
  end
  
  describe "#ensure_all_orders_stores" do
    
    before :each do
      @order = FactoryGirl.create(:order)
      @line_item = FactoryGirl.build(:line_item, :order => @order)
      @line_item_2 = FactoryGirl.build(:line_item, :order => @order)
      @line_item_3 = FactoryGirl.build(:line_item, :order => @order)
    end
    
    it "should create all stores when no orders_stores exist" do
      # stubbing out ensure_orders_store, so that none of the below get added to the order when they're created
      @order.stub!(:ensure_orders_store)
      @line_item.save
      @line_item_2.save
      @line_item_3.save
      
      # verify that none of the orders_stores were added
      @order.orders_stores.size.should == 0
      @order.ensure_all_orders_stores
      
      # verify that there are 3 OrdersStores
      @order.orders_stores.size.should == 3
      
      # verify that each line item's store exists as an OrdersStore
      [@line_item, @line_item_2, @line_item_3].each do |line_item|
        added_orders_store = @order.orders_stores.find_by_store_id(line_item.store)
        added_orders_store.should_not be_nil
        added_orders_store.store.should == line_item.store
        added_orders_store.order.should == @order
      end
    end
    
    it "should create OrdersStores that don't exist when there already exist some OrdersStores" do
      @line_item.save
      @line_item_2.save
      # stubbing out ensure_orders_store, so that none of the below get added to the order when they're created
      @order.stub!(:ensure_orders_store)
      @line_item_3.save
      @order.orders_stores.size.should == 2
      [@line_item, @line_item_2].each do |line_item|
        added_orders_store = @order.orders_stores.find_by_store_id(line_item.store)
        added_orders_store.should_not be_nil
        added_orders_store.store.should == line_item.store
        added_orders_store.order.should == @order
      end
      
      @order.ensure_all_orders_stores
      
      @order.orders_stores.size.should == 3
      [@line_item, @line_item_2, @line_item_3].each do |line_item|
        added_orders_store = @order.orders_stores.find_by_store_id(line_item.store)
        added_orders_store.should_not be_nil
        added_orders_store.store.should == line_item.store
        added_orders_store.order.should == @order
      end
    end
    
    it "should not create any OrdersStoers when all of them already exist" do
      @line_item.save
      @line_item_2.save
      @line_item_3.save
      @order.orders_stores.size.should == 3
      [@line_item, @line_item_2, @line_item_3].each do |line_item|
        added_orders_store = @order.orders_stores.find_by_store_id(line_item.store)
        added_orders_store.should_not be_nil
        added_orders_store.store.should == line_item.store
        added_orders_store.order.should == @order
      end
      
      @order.ensure_all_orders_stores
      
      @order.orders_stores.size.should == 3
      [@line_item, @line_item_2, @line_item_3].each do |line_item|
        added_orders_store = @order.orders_stores.find_by_store_id(line_item.store)
        added_orders_store.should_not be_nil
        added_orders_store.store.should == line_item.store
        added_orders_store.order.should == @order
      end
    end
    
    it "should remove an OrdersStore that does not have any line_items attached to it" do
      @line_item.save
      @line_item_2.save
      @line_item_3.save
      @store_4 = FactoryGirl.create(:store)
      @order.orders_stores.create(:store => @store_4)
      @order.orders_stores.size.should == 4
      
      @order.ensure_all_orders_stores
      @order.orders_stores.size.should == 3
      [@line_item, @line_item_2, @line_item_3].each do |line_item|
        added_orders_store = @order.orders_stores.find_by_store_id(line_item.store)
        added_orders_store.should_not be_nil
        added_orders_store.store.should == line_item.store
        added_orders_store.order.should == @order
      end
    end
    
  end
  
  describe "#check_to_remove_orders_store" do
    
    before :each do
      @order = FactoryGirl.create(:order)
    end
    
    it "should remove a store if the only line item in an order for that store is removed" do
      @line_item = FactoryGirl.build(:line_item, :order => @order)
      @order.ensure_orders_store(@line_item.store)
      @order.orders_stores.size.should == 1
      @order.check_to_remove_orders_store(@line_item.store)
      @order.orders_stores.size.should == 0
    end
    
    it "should not remove a store if there exists other line items that link to the store" do
      @line_item_1 = FactoryGirl.create(:line_item, :order => @order)
      @line_item_2 = FactoryGirl.build(:line_item, :order => @order, :store => @line_item_1.store)
      @order.ensure_orders_store(@line_item_2.store)
      @order.orders_stores.size.should == 1
      @order.check_to_remove_orders_store(@line_item_2.store)
      @order.orders_stores.size.should == 1
    end
    
  end
  
  describe "#calculate_orders_stores" do
    
    before :each do
      @order = FactoryGirl.create(:order)
      @line_item = FactoryGirl.create(:line_item, :order => @order)
      @line_item_2 = FactoryGirl.create(:line_item, :order => @order)
      @order.ensure_all_orders_stores
    end
    
    it "should calculate the amounts for each store" do
      OrdersStore.any_instance.stub(:calculate!)
      
      @order.orders_stores.each do |orders_store|
        orders_store.should_receive(:calculate!)
      end
      @order.calculate_orders_stores
    end
    
  end
  
  describe "#lock_line_item_commission_percentages" do
    
    before :each do
      @order = FactoryGirl.create(:order)
      @line_item = FactoryGirl.create(:line_item, :order => @order)
      @line_item_2 = FactoryGirl.create(:line_item, :order => @order)
      @order.ensure_all_orders_stores
    end
    
    it "should set all the orders_stores to open" do
      LineItem.any_instance.stub(:update_attribute_without_callbacks)
      
      @order.line_items.each do |line_item|
        line_item.should_receive(:update_attribute_without_callbacks).with('commission_percentage_lock', true)
      end
      @order.lock_line_item_commission_percentages
    end
    
  end
  
  describe "#open_orders_stores" do
    
    before :each do
      @order = FactoryGirl.create(:order)
      @line_item = FactoryGirl.create(:line_item, :order => @order)
      @line_item_2 = FactoryGirl.create(:line_item, :order => @order)
      @order.ensure_all_orders_stores
    end
    
    it "should set all the orders_stores to open" do
      OrdersStore.any_instance.stub(:ready!)
      
      @order.orders_stores.each do |orders_store|
        orders_store.should_receive(:ready!)
      end
      @order.open_orders_stores
    end
    
  end
  
  describe "#soletron_commission_base" do
    
    it "should be the item total after the coupon total" do
      scenarios = [{:item_total => 100.00, :coupon_total => 0.00, :base => 100.00},
                   {:item_total => 20.00, :coupon_total => -5.00, :base => 15.00}]
      
      scenarios.each do |scenario|
        order = FactoryGirl.create(:order, :item_total => scenario[:item_total])
        order.stub!(:coupon_total).and_return(scenario[:coupon_total])
        order.soletron_commission_base.should == scenario[:base]
      end
    end
    
  end
  
  describe "#soletron_commission" do
    
    it "should be the amount that soletron earns" do
      scenarios = [{:item_total => 100.00, :coupon_total => 0.00, :product_reimbursement => 70.00, :coupons => 0.00, :commission => 30.00},
                   {:item_total => 100.00, :coupon_total => -10.00, :product_reimbursement => 60.00, :coupons => -6.00, :commission => 36.00}]
      
      scenarios.each do |scenario|
        order = FactoryGirl.create(:order, :item_total => scenario[:item_total])
        order.stub!(:coupon_total).and_return(scenario[:coupon_total])
        order.orders_stores.stub!(:sum).with(:product_reimbursement).and_return(scenario[:product_reimbursement])
        order.orders_stores.stub!(:sum).with(:coupons).and_return(scenario[:coupons])
        order.soletron_commission.should == scenario[:commission]
      end
    end
    
  end
  
  describe "#soletron_commission_rate" do
    
    it "should be the weighted average commission rate of the products purchased" do
      scenarios = [{:item_total => 100.00, :coupon_total => 0.00, :product_reimbursement => 70.00, :coupons => 0.00, :commission_rate => 30.0},
                   {:item_total => 100.00, :coupon_total => -10.00, :product_reimbursement => 60.00, :coupons => -6.00, :commission_rate => 40.00}]
      
      scenarios.each do |scenario|
        order = FactoryGirl.create(:order, :item_total => scenario[:item_total])
        order.stub!(:coupon_total).and_return(scenario[:coupon_total])
        order.orders_stores.stub!(:sum).with(:product_reimbursement).and_return(scenario[:product_reimbursement])
        order.orders_stores.stub!(:sum).with(:coupons).and_return(scenario[:coupons])
        order.soletron_commission_rate.should == scenario[:commission_rate]
      end
    end
    
  end
  
  context "class methods" do
    
    describe "#update_shipment_states" do
      
      before :each do
        OrdersStore.delete_all
        order = Factory.custom_order :late => true
        order.update_attribute_without_callbacks 'shipment_state', 'ready'
        order.orders_stores.each { |orders_store| orders_store.update_attribute_without_callbacks :state, 'open' }
        order.line_items.each { |line_item| line_item.update_attribute_without_callbacks :state, 'open' }
        order.update_attribute_without_callbacks 'payment_state', 'paid'
      end
      
      it "should update all line items that haven't been closed yet and are late to past_due" do
        Spree::LineItem.past_due.count.should == 0
        Spree::Order.update_shipment_states
        Spree::LineItem.past_due.count.should > 0
        Spree::LineItem.open.count.should == 0
      end
      
      it "should update all orders_stores that haven't been completed yet and are late to past_due" do
        OrdersStore.past_due.count.should == 0
        Spree::Order.update_shipment_states
        OrdersStore.past_due.count.should > 0
        OrdersStore.where(:state => 'open').count.should == 0
      end
      
      it "should update all orders that haven't been shipped yet and are late to past_due" do
        Spree::Order.need_to_ship.where(:shipment_state => 'ready').count.should > 0
        Spree::Order.update_shipment_states
        Spree::Order.past_due.count.should > 0
        Spree::Order.need_to_ship.where(:shipment_state => 'ready').count.should == 0
      end
      
    end
    
  end

  describe "#process_coupon_code" do
    
    it "should return false" do
      FactoryGirl.build(:order).process_coupon_code.should == true
    end
    
  end

  describe "processing promotions" do

    describe "#process_automatic_promotions" do

      before :each do
        @order = Spree::Config.temp_set(allow_backorders: true, allow_backorder_shipping: true) {
          FactoryGirl.create(:order)
        }
        @line_item_1 = Spree::Config.temp_set(allow_backorders: true, allow_backorder_shipping: true) {
          FactoryGirl.create(:open_line_item, quantity: 1, price: 10.00, order: @order)
        }
        @line_item_1.variant.product.master.update_attribute_without_callbacks :price, 10.0
        @line_item_1.update_attribute_without_callbacks :price, 10.0
        @line_item_2 = Spree::Config.temp_set(allow_backorders: true, allow_backorder_shipping: true) {
          FactoryGirl.create(:open_line_item, quantity: 2, price: 20.00, order: @order)
        }
        @line_item_2.variant.product.master.update_attribute_without_callbacks :price, 20.0
        @line_item_2.update_attribute_without_callbacks :price, 20.0
        @order.line_items.reload
        #puts @order.line_items.inspect
        @order.update!
        puts "order updated"
        @promotion = FactoryGirl.create(:flat_percent_automatic_promotion)
        puts "promotion created"
        puts "  #{@promotion.inspect}"
        @promotion.promotion_actions.first.calculator.set_preference :flat_percent_off, 50.0
        @promotion.promotion_actions.first.calculator.save
        puts "  calculator saved"
        puts "  eligible? #{@promotion.eligible?(@order)}"
        puts "  automatic? #{@promotion.automatic?}"
      end

      it "should reuse existing promotion credits" do
        puts "\n\nStart Test: should reuse existing promotion credits\n\n"
        promotion_credit = FactoryGirl.create(:promotion_credit, adjustable: @order, source: @promotion)
        puts "promotion credit added #{promotion_credit.inspect}"
        puts "promotion credits #{@order.promotion_credits.inspect}"
        promotion_credit.source.stub!(:eligible?).and_return(true)
        @order.adjustments << promotion_credit
        puts " promotion credits #{@order.promotion_credits.inspect}"
        @order.promotion_credits.count.should == 1
        @order.process_automatic_promotions
        puts "processed automatic promotions"
        @order.promotion_credits.count.should == 1
        @order.promotion_credits.first.should == promotion_credit
        #puts @order.promotion_credits.inspect
        @order.promotion_credits.map(&:amount).sum.should == -25
      end

      it "should create a promotion credit for each eligible coupon" do
        puts "\n\nStart Test: should create a promotion credit for each eligible coupon\n\n"
        puts "preferences #{@promotion.promotion_actions.first.calculator.preferences.inspect}"
        @order.coupon_code = @promotion.code
        puts "ADDED COUPON CODE"
        @order.process_automatic_promotions
        @order.promotion_credits.count.should == 1
        @order.promotion_credits.map(&:amount).sum.should == -25

        @order.update!
        @order.promotion_credits.map(&:amount).sum.should == -25
      end

      it "should have promotion credits for the previous promotion but not the new one, since the discount already happened" do
        new_promotion = FactoryGirl.create(:flat_percent_promotion)
        new_promotion.promotion_actions.first.calculator.set_preference :flat_percent_off, 20.0
        promotion_credit = FactoryGirl.create(:promotion_credit, source: @promotion, adjustable: @order)
        promotion_credit.source.stub!(:eligible?).and_return(true)
        @order.promotion_credits << promotion_credit
        @order.coupon_code = new_promotion.code
        @order.process_automatic_promotions
        @order.promotion_credits.reload
        @order.promotion_credits.count.should == 1
        @order.promotion_credits.map(&:amount).sum.should == -25
      end
      
      it "should have the proper line item promotion credits" do
        @order.coupon_code = @promotion.code
        #puts "preferences #{@promotion.calculator.preferences.inspect}"
        #puts "ADDED COUPON CODE"
        @order.process_automatic_promotions
        @order.promotion_credits.count.should == 1
        
        promotion_credit = @order.promotion_credits.first
        
        lipc_amounts = {
          @line_item_1.id => {
            quantity: 1,
            amount: -5.0
          },
          @line_item_2.id => {
            quantity: 2,
            amount: -20.0
          }
        }
        
        promotion_credit.line_item_promotion_credits.count.should == 2
        promotion_credit.line_item_promotion_credits.each do |lipc|
          lipc_data = lipc_amounts.delete(lipc.line_item_id)
          lipc_data.should_not be_nil
          lipc.quantity.should == lipc_data[:quantity]
          lipc.amount.should == lipc_data[:amount]
        end
      end
      
      it "should continue to have the promotion credits sum to the corrent amount after two run throughs" do
        #puts "preferences #{@promotion.calculator.preferences.inspect}"
        @order.coupon_code = @promotion.code
        #puts "ADDED COUPON CODE"
        puts "\n\n\nTEST for processing automatic promotions\n\n\n"
        @order.process_automatic_promotions
        @order.process_automatic_promotions
        @order.promotion_credits.count.should == 1
        @order.promotion_credits.map(&:amount).sum.should == -25

        @order.update!
        @order.promotion_credits.map(&:amount).sum.should == -25
      end

    end


    describe "#build_current_promotions" do

      before :each do

      end

      it "should build a set of the promotions that can be used" do

      end

    end

    describe "#update_promotion_credit" do

      before :each do
        @promotion = FactoryGirl.create(:promotion)
        @order = FactoryGirl.create(:order)
      end

      it "should create a new promotion credit when none is sent" do
        promotion_credit = @order.send :update_promotion_credit, @promotion, 10.00
        promotion_credit.should_not be_nil
        promotion_credit.errors.size.should == 0
        promotion_credit.amount.should == 10.00
        promotion_credit.source.should == @promotion
      end

      it "should update the promotion credit sent" do
        promotion_credit = FactoryGirl.create(:promotion_credit, :source_id => @promotion.id, :source_type => 'Promotion')
        updated_promotion_credit = @order.send :update_promotion_credit, @promotion, 10.00, promotion_credit
        updated_promotion_credit.should_not be_nil
        updated_promotion_credit.amount.should == 10
        updated_promotion_credit.source.should == @promotion
      end

    end

    describe "#update_line_item_promotion_credits" do

      before :each do
        @order = FactoryGirl.build(:order)
        @promotion_credit = FactoryGirl.create(:promotion_credit, :order => @order)
      end

      it "should update the line item promotion credits" do
        line_item_promotion_credits = []
        line_item_promotion_credits << FactoryGirl.build(:line_item_promotion_credit)
        line_item_promotion_credits << FactoryGirl.build(:line_item_promotion_credit)

        @order.send(:update_line_item_promotion_credits, @promotion_credit, line_item_promotion_credits).each do |lipc|
          lipc.promotion_credit.should == @promotion_credit
          lipc.errors.size.should == 0
        end
      end

    end
  end

end

