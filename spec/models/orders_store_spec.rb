require 'spec_helper'

describe OrdersStore do
  context "shoulda validations" do
    it { should belong_to(:order) }
    it { should belong_to(:store) }
  end
  
  describe "#line_items" do
    before :each do
      @order = FactoryGirl.create(:order)
      @line_item = FactoryGirl.create(:line_item, :order => @order)
      @order.ensure_all_orders_stores
      @orders_store = @order.orders_stores.first
    end
    
    it "should return only line items attached to the same store" do
      @store = @line_item.store
      FactoryGirl.create(:line_item, :order => @order, :store => @store) # second line_item
      FactoryGirl.create(:line_item, :order => @order)
      FactoryGirl.create(:line_item, :order => @order)
      FactoryGirl.create(:line_item, :order => @order)
      
      @orders_store.line_items.count.should == 2
      @orders_store.line_items.each do |line_item|
        line_item.store.should == @store
      end
    end
  end
  
  describe "#shipments" do
    
    before :each do
      FactoryGirl.create(:promotion, :code => 'Facebooktest')
      @order = FactoryGirl.create(:complete_order)
      @order.save
      @orders_store = @order.orders_stores.first
      @store = @orders_store.store
    end
    
    it "should return shipments attached to the same store" do
      @orders_store.shipments.size.should == 1
      @orders_store.shipments.each do |shipment|
        shipment.order.should == @order
        shipment.store.should == @store
      end
    end
    
  end
  
  describe "#remaining_to_ship" do
    
    it "should return only non-shipped items" do
      @orders_store = FactoryGirl.create(:open_orders_store)
      @orders_store.remaining_to_ship.each do |inventory_unit|
        inventory_unit.shipped?.should == false
        inventory_unit.canceled?.should == false
      end
    end
    
    it "should return no non-shipped items" do
      @orders_store = FactoryGirl.create(:complete_orders_store)
      @orders_store.remaining_to_ship.size.should == 0
    end
    
  end
  
  describe "#open_shipment_late?" do
    
    it "should return false if the order was completed within two days of now" do
      @orders_store = FactoryGirl.create(:open_orders_store)
      @orders_store.open_shipment_late?.should == false
    end
    
    it "should return true if the order was completed more than two days ago" do
      @orders_store = FactoryGirl.create(:open_late_orders_store)
      @orders_store.open_shipment_late?.should == true
    end
    
    it "should return true if the order was completed exactly two days ago" do
      @orders_store = FactoryGirl.create(:open_orders_store)
      now = Time.now.utc
      two_days_ago = now - 2.days
      Time.now.stub!(:utc).and_return(now)
      @orders_store.order.completed_at = two_days_ago
      @orders_store.order.save
      @orders_store.open_shipment_late?.should == true
    end
    
  end
  
  describe "#all_shipped_on_time?" do

    it "should return false when a shipment was not shipped" do
      @orders_store = FactoryGirl.create(:orders_store)
      @orders_store.all_shipped_on_time? == false
    end
    
    it "should return false when a shipment was shipped late" do
      @orders_store = FactoryGirl.create(:closed_late_orders_store)
      @orders_store.all_shipped_on_time? == false
    end
    
    it "should return true when all shipment were shipped on time" do
      @orders_store = FactoryGirl.create(:complete_orders_store)
      @orders_store.all_shipped_on_time? == true
    end
    
  end
  
  describe "#all_shipped?" do
    
    it "should return false if the shipment has not shipped" do
      @orders_store = FactoryGirl.create(:open_orders_store)
      @orders_store.all_shipped?.should == false
    end
    
    it "should return true if the shipment has shipped" do
      @orders_store = FactoryGirl.create(:complete_orders_store)
      @orders_store.all_shipped?.should == true
    end
    
  end
  
  describe "#none_shipped?" do
    
    it "should return false if the shipment has shipped" do
      @orders_store = FactoryGirl.create(:complete_orders_store)
      @orders_store.none_shipped?.should == false
    end
    
    it "should return true if the shipment has not shipped" do
      @orders_store = FactoryGirl.create(:open_orders_store)
      @orders_store.none_shipped?.should == true
    end
    
  end
  
  describe "state transitions" do
    
    describe "#ready"
    
    describe "#check_if_late" do
      
      it "should call #open_shipment_late?" do
        @orders_store = FactoryGirl.create(:open_orders_store)
        @orders_store.should_receive(:open_shipment_late?)
        @orders_store.check_if_late
      end
      
    end
    
    describe "#shipped" do
      
      it "should call #all_shipped_lon_time? when open and on time" do
        @orders_store = FactoryGirl.create(:open_orders_store)
        @orders_store.should_receive(:all_shipped_on_time?)
        @orders_store.shipped
      end
      
      it "should call #all_shipped_on_time? and #all_shipped? when open and the order is late" do
        @orders_store = FactoryGirl.create(:open_late_orders_store)
        @orders_store.should_receive(:all_shipped_on_time?)
        @orders_store.should_receive(:all_shipped?)
        @orders_store.shipped
      end
      
      it "should call #all_shipped? when past due and the order is late" do
        @orders_store = FactoryGirl.create(:past_due_orders_store)
        @orders_store.should_not_receive(:all_shipped_on_time?)
        @orders_store.should_receive(:all_shipped?)
        @orders_store.shipped
      end
      
    end
    
    describe "#cancel_remaining" do
      
      it "should call #none_shipped?" do
        @orders_store = FactoryGirl.create(:open_orders_store)
        none_shipped = @orders_store.none_shipped?
        @orders_store.stub!(:none_shipped?).and_return(none_shipped)
        @orders_store.should_receive(:none_shipped?)
        @orders_store.cancel_remaining
      end
      
      it "should transition to canceled none have been shipped" do
        @orders_store = FactoryGirl.create(:open_orders_store)
        @orders_store.cancel_remaining
        @orders_store.canceled?.should == true
      end
      
      it "should transition to shipped when some have been shipped" do
        @orders_store = FactoryGirl.create(:complete_orders_store)
        @orders_store.cancel_remaining
        @orders_store.shipped?.should == true
      end
      
      it "should have all inventory units be either shipped or canceled" do
        @orders_store = FactoryGirl.create(:open_orders_store)
        @orders_store.cancel_remaining!
        @orders_store.inventory_units.each do |inventory_unit|
          (inventory_unit.shipped? || inventory_unit.canceled?).should == true
        end
      end
      
    end
    
    describe "#cancel" do
      
      it "should migrate to canceled when all items canceled" do
        @orders_store = FactoryGirl.create(:canceled_orders_store)
        #@orders_store.line_items.each do |line_item|
        #  line_item.update_attribute_without_callback 'state', :canceled
        #end
        @orders_store.update_attribute_without_callbacks 'state', 'open'
        @orders_store.cancel!
        @orders_store.canceled?.should == true
      end
      
      it "should migrate to complete when all non-canceled items were shipped on time" do
        @orders_store = FactoryGirl.create(:complete_orders_store)
        @orders_store.update_attribute_without_callbacks 'state', 'open'
        
        shipments = []
        2.times do |i|
          shipment = Spree::Shipment.new(:state => :canceled)
          shipment.stub!(:late?).and_return(false)
          shipment.stub!(:shipped?).and_return(true)
          shipments << shipment
        end
        @orders_store.stub!(:shipments).and_return(shipments)
        
        @orders_store.cancel!
        @orders_store.complete?.should == true
      end
      
      it "should migrate to closed_late when at least one non-canceled item was shipped late" do
        @orders_store = FactoryGirl.create(:closed_late_orders_store)
        @orders_store.update_attribute_without_callbacks 'state', 'open'
        
        shipments = []
        2.times do |i|
          shipment = Spree::Shipment.new(:state => :canceled)
          shipment.stub!(:late?).and_return(true)
          shipment.stub!(:shipped?).and_return(true)
          shipments << shipment
        end
        @orders_store.stub!(:shipments).and_return(shipments)
        
        @orders_store.cancel
        @orders_store.closed_late?.should == true
      end
      
    end
    
    describe "#force_cancel" do
      
      it "should transition to canceled when open" do
        @orders_store = FactoryGirl.create(:open_orders_store)
        @orders_store.force_cancel
        @orders_store.canceled?.should == true
      end
      
      it "should transition to canceled when shipped" do
        @orders_store = FactoryGirl.create(:complete_orders_store)
        @orders_store.force_cancel
        @orders_store.canceled?.should == true
      end
      
    end
    
  end
  
  describe "#calculate!" do
    before :each do
      @order = FactoryGirl.create(:order)
      @line_item = FactoryGirl.create(:line_item, :order => @order)
      @order.ensure_all_orders_stores
      @orders_store = @order.orders_stores.first
    end
    
    it "should calculate the amounts for each store" do
      @orders_store.stub!(:calculate_line_items!)
      @orders_store.stub!(:calculate_product_sales!)
      @orders_store.stub!(:calculate_shipping!)
      @orders_store.stub!(:calculate_coupons!)
      @orders_store.stub!(:calculate_product_reimbursement!)
      @orders_store.stub!(:calculate_total_reimbursement!)
      @orders_store.stub!(:calculate_total_amount!)
      @orders_store.stub!(:save)
      
      @orders_store.should_receive(:calculate_line_items!)
      @orders_store.should_receive(:calculate_product_sales!)
      @orders_store.should_receive(:calculate_shipping!)
      @orders_store.should_receive(:calculate_coupons!)
      @orders_store.should_receive(:calculate_product_reimbursement!)
      @orders_store.should_receive(:calculate_total_reimbursement!)
      @orders_store.should_receive(:calculate_total_amount!)
      @orders_store.should_receive(:save)
      
      @orders_store.calculate!
    end
    
    it "should properly update the vendor payment period when it exists"
    
  end
  
  describe "#calculate_line_items!" do
    
    before :each do
      @order = FactoryGirl.create(:complete_order)
      @orders_store = @order.orders_stores.first
    end
    
    it "should calculate each line item" do
      @orders_store.line_items.each do |line_item|
        line_item.stub!(:calculate!)
        line_item.should_receive(:calculate!)
      end
      @orders_store.send(:calculate_line_items!)
    end
    
  end
  
  describe "#calculate_product_sales!" do
    
    before :each do
      @order = FactoryGirl.create(:complete_order)
      @orders_store = @order.orders_stores.first
    end
    
    it "should access the quantity of each line item" do
      @orders_store.line_items.each do |line_item|
        line_item.stub!(:quantity).and_return(5)
        line_item.should_receive(:quantity)
      end
      @orders_store.send(:calculate_product_sales!)
    end
    
    it "should access the price of each line item" do
      @orders_store.line_items.each do |line_item|
        line_item.stub!(:price).and_return(10.0)
        line_item.should_receive(:price)
      end
      @orders_store.send(:calculate_product_sales!)
    end
    
    it "should calculate product sales from the line items" do
      expected_cost = 0
      @orders_store.line_items.each do |line_item|
        expected_cost += line_item.quantity * line_item.price
      end
      @orders_store.send(:calculate_product_sales!)
      @orders_store.product_sales.should == expected_cost
    end
    
    it "should not be greater than the amount in the order" do
      @orders_store.send(:calculate_product_sales!)
      order_total = 0
      @order.line_items.each do |line_item|
        order_total += line_item.amount
      end
      orders_store_total = 0
      @orders_store.line_items.each do |line_item|
        orders_store_total += line_item.amount
      end
      @orders_store.product_sales.should_not > @order.item_total
    end
    
  end
  
  describe "#calculate_product_reimbursement!" do
    
    before :each do
      @order = FactoryGirl.create(:complete_order)
      @orders_store = @order.orders_stores.first
    end
    
    it "should be the sum of the store_amounts from the line items" do
      expected = 0
      @orders_store.line_items.each do |line_item|
        expected += line_item.store_amount
      end
      @orders_store.send(:calculate_product_reimbursement!)
      @orders_store.product_reimbursement.should == expected
    end
    
    it "should not be greater than product sales" do
      @orders_store.send(:calculate_product_reimbursement!)
      @orders_store.product_reimbursement.should_not > @orders_store.product_sales
    end
    
  end
    
  
  describe "#calculate_shipping!" do
    
    before :each do
      @order = FactoryGirl.create(:complete_order)
      @orders_store = @order.orders_stores.first
    end
    
    it "should access the adjustment amount from the related Shipment" do
      @orders_store.shipments.each do |shipment|
        shipment.adjustment.stub!(:amount).and_return(50)
        shipment.adjustment.should_receive(:amount)
      end
      @orders_store.send :calculate_shipping!
    end
    
    it "should have the same value as the related Shipment" do
      expected = 0
      @orders_store.shipments.each do |shipment|
        expected += shipment.adjustment.amount
      end
      @orders_store.send :calculate_shipping!
      @orders_store.shipping.should == expected
    end
    
  end
  
  describe "coupons" do
    
    describe "#calculate_lipc_coupons" do
      
      it "should be equal to the sum of the amounts of the line item promotion credits attached to the line items" do
        @orders_store = OrdersStore.new
        
        [
          {
            line_item_promotion_credits: [
              LineItemPromotionCredit.new(amount: 10.0),
              LineItemPromotionCredit.new(amount: 15.0),
              LineItemPromotionCredit.new(amount: 20.0)
            ],
            value: 45.00
          },
          {
            line_item_promotion_credits: [
              LineItemPromotionCredit.new(amount: 10.0),
              LineItemPromotionCredit.new(amount: 15.0),
              LineItemPromotionCredit.new(amount: 20.0),
              LineItemPromotionCredit.new(amount: 30.0)
            ],
            value: 75.00
          },
          {
            line_item_promotion_credits: [
              LineItemPromotionCredit.new(amount: 10.0)
            ],
            value: 10.00
          }
        ].each do |scenario|
          @orders_store.stub!(:line_item_promotion_credits).and_return(scenario[:line_item_promotion_credits])
          @orders_store.send(:calculate_lipc_coupons).should == scenario[:value]
        end
      end
      
    end
    
    describe "#calculate_lipc_store_coupons" do
      
      it "should be equal to the sum of the amounts of the line item promotion credits attached to the line items" do
        @orders_store = OrdersStore.new
        
        [
          {
            line_item_promotion_credits: [
              {amount: 10.0, commission_percentage: 30.0},
              {amount: 15.0, commission_percentage: 30.0},
              {amount: 20.0, commission_percentage: 40.0}
            ],
            value: 29.50
          },
          {
            line_item_promotion_credits: [
              {amount: 10.0, commission_percentage: 30.0},
              {amount: 15.0, commission_percentage: 30.0},
              {amount: 20.0, commission_percentage: 40.0},
              {amount: 30.0, commission_percentage: 40.0}
            ],
            value: 47.50
          },
          {
            line_item_promotion_credits: [
              {amount: 10.0, commission_percentage: 30.0}
            ],
            value: 7.00
          }
        ].each do |scenario|
          line_item_promotion_credits = []
          scenario[:line_item_promotion_credits].each do |lipc_data|
            #puts "lipc data #{lipc_data.inspect}"
            #puts "  commission_percentage #{lipc_data[:commission_percentage]}"
            lipc = LineItemPromotionCredit.new(amount: lipc_data[:amount])
            #line_item = LineItem.new(commission_percentage: lipc_data[:commission_percentage])
            line_item = LineItem.new
            line_item.commission_percentage = lipc_data[:commission_percentage]
            lipc.line_item = line_item
            #puts line_item.inspect
            line_item_promotion_credits << lipc
          end
          @orders_store.stub!(:line_item_promotion_credits).and_return(line_item_promotion_credits)
          #puts "lipcs:\n  #{@orders_store.line_item_promotion_credits}"
          @orders_store.send(:calculate_lipc_store_coupons).should == scenario[:value]
        end
      end
      
    end
    
    describe "#calculate_free_shipping_coupons" do
      
      it "should be equal to the order store's shipping amount if the free shipping promotion adjustments on the 
          order are equal to the order's shipping costs" do
        @orders_store = OrdersStore.new(order: Order.new)
        
        [
          {
            shipping_total: 100.00,
            free_shipping_coupon_total: 100.00,
            shipping: 100.00,
            value: 100.00
          },
          {
            shipping_total: 10.00,
            free_shipping_coupon_total: 100.00,
            shipping: 100.00,
            value: 0.0
          },
          {
            shipping_total: 100.00,
            free_shipping_coupon_total: 5.00,
            shipping: 100.00,
            value: 0.0
          },
        ].each do |scenario|
          @orders_store.order.stub!(:shipping_total).and_return(scenario[:shipping_total])
          @orders_store.order.stub!(:free_shipping_coupon_total).and_return(scenario[:free_shipping_coupon_total])
          @orders_store.stub!(:shipping).and_return(scenario[:shipping])
          @orders_store.send(:calculate_free_shipping_coupons).should == scenario[:value]
        end
        
      end
      
    end
    
    describe "#calculate_other_coupons" do
      
      it "should sum up all coupons that neither have line item promotion credits nor are free shipping coupons
          proportional to the product sales amount of the store relative to the item total of the order" do
        @orders_store = OrdersStore.new(order: Order.new)
        
        [
          {
            item_total: 10.0,
            product_sales_proportion: 0.5,
            promotion_credits: [
              PromotionCredit.new(amount: -20.0),
              PromotionCredit.new(amount: -10.0)
            ],
            value: -15.0
          },
          {
            item_total: 10.0,
            product_sales_proportion: 1.0,
            promotion_credits: [
              PromotionCredit.new(amount: -20.0)
            ],
            value: -20.0
          },
          {
            item_total: 10.0,
            product_sales_proportion: 0.2,
            promotion_credits: [
              PromotionCredit.new(amount: -20.0),
              PromotionCredit.new(amount: -15.0),
              PromotionCredit.new(amount: -10.0)
            ],
            value: -9.0
          },
          {
            item_total: 0.0,
            product_sales_proportion: 0.2,
            promotion_credits: [
              PromotionCredit.new(amount: -20.0),
              PromotionCredit.new(amount: -15.0),
              PromotionCredit.new(amount: -10.0)
            ],
            value: 0.0
          }
        ].each do |scenario|
          @orders_store.stub!(:product_sales_proportion).and_return(scenario[:product_sales_proportion])
          @orders_store.order.stub!(:item_total).and_return(scenario[:item_total])
          @orders_store.order.stub!(:not_free_shipping_nor_lipc_promotions).and_return(scenario[:promotion_credits])
          @orders_store.send(:calculate_other_coupons).should == scenario[:value]
        end
      end
      
    end
    
    describe "#calculate_coupons!" do
      
      it "should have an amount of coupons relative to the size of the store's total from the order" do
        @orders_store = OrdersStore.new(order: Order.new)
        
        [
          {
            :item_total => 50.0, 
            :calculate_free_shipping_coupons => -10.0, 
            :calculate_lipc_coupons => 0.0, 
            :calculate_other_coupons => -5.0, 
            :product_sales => 50.0,
            :coupons => -15.0
          },
          {
            :item_total => 100.0, 
            :calculate_free_shipping_coupons => -20.0, 
            :calculate_lipc_coupons => -20.0, 
            :calculate_other_coupons => 0.0, 
            :product_sales => 150.0,
            :coupons => -40.0
          },
          {
            :item_total => 0.00, 
            :calculate_free_shipping_coupons => -20.0, 
            :calculate_lipc_coupons => -10.0, 
            :calculate_other_coupons => -10.0,
            :product_sales => 10.0,
            :coupons => -10.0
          }#,
          # the following checks for penny rounding
          #{
          #  :item_total => 19.99, 
          #  :calculate_free_shipping_coupons => -5.00, 
          #  :calculate_lipc_coupons => 11.99, 
          #  :calculate_other_coupons => 11.99, 
          #  :product_sales => 10.0
          #  :coupons => -3.00
          #}
        ].each do |scenario|
          @orders_store.order.stub!(:item_total).and_return(scenario[:item_total])
          @orders_store.stub!(:calculate_free_shipping_coupons).and_return(scenario[:calculate_free_shipping_coupons])
          @orders_store.stub!(:calculate_lipc_coupons).and_return(scenario[:calculate_lipc_coupons])
          @orders_store.stub!(:calculate_other_coupons).and_return(scenario[:calculate_other_coupons])
          @orders_store.stub!(:product_sales).and_return(scenario[:product_sales])
          @orders_store.send :calculate_coupons!
          
          @orders_store.coupons.should == scenario[:coupons]
        end
      end
      
      
      ##
      # Integration tests that could be done later
      ##
      it "should have an amount of coupons that takes into account store-specific coupons"
      it "should have an amount of coupons that takes into account product-specific coupons"
      
    end
    
  end
  
  describe "#calculate_store_coupons!" do
    
    it "should have an amount of coupons relative to the size of the store's total from the order" do
      @orders_store = OrdersStore.new(order: Order.new)
      
      [
        {
          :item_total => 50.0, 
          :calculate_free_shipping_coupons => -10.0, 
          :calculate_lipc_coupons => 0.0, 
          :calculate_lipc_store_coupons => 0.0, 
          :calculate_other_coupons => -5.0, 
          :product_reimbursement => 35.0, 
          :product_sales => 50.0,
          :coupons => -15.0,
          :store_coupons => -13.5
        },
        {
          :item_total => 100.0, 
          :calculate_free_shipping_coupons => -20.0, 
          :calculate_lipc_coupons => -20.0, 
          :calculate_lipc_store_coupons => -15.0, 
          :calculate_other_coupons => 0.0, 
          :product_reimbursement => 70.0, 
          :product_sales => 150.0,
          :coupons => -40.0,
          :store_coupons => -35.0
        },
        {
          :item_total => 0.00, 
          :calculate_free_shipping_coupons => -20.0, 
          :calculate_lipc_coupons => -10.0, 
          :calculate_lipc_store_coupons => -8.0, 
          :calculate_other_coupons => -10.0,
          :product_reimbursement => 0.0,
          :product_sales => 10.0,
          :coupons => -10.0,
          :store_coupons => 0
        }#,
        # the following checks for penny rounding
        #{
        #  :item_total => 19.99, 
        #  :calculate_free_shipping_coupons => -5.00, 
        #  :calculate_lipc_coupons => 11.99, 
        #  :calculate_other_coupons => 11.99, 
        #  :product_sales => 10.0
        #  :coupons => -3.00
        #}
      ].each do |scenario|
        @orders_store.order.stub!(:item_total).and_return(scenario[:item_total])
        @orders_store.stub!(:calculate_free_shipping_coupons).and_return(scenario[:calculate_free_shipping_coupons])
        @orders_store.stub!(:calculate_lipc_coupons).and_return(scenario[:calculate_lipc_coupons])
        @orders_store.stub!(:calculate_lipc_store_coupons).and_return(scenario[:calculate_lipc_store_coupons])
        @orders_store.stub!(:calculate_other_coupons).and_return(scenario[:calculate_other_coupons])
        @orders_store.stub!(:product_reimbursement).and_return(scenario[:product_reimbursement])
        @orders_store.stub!(:product_sales).and_return(scenario[:product_sales])
        @orders_store.send :calculate_store_coupons!
        
        @orders_store.store_coupons.should == scenario[:store_coupons]
      end
    end
    
  end
  
  describe "#calculate_total_amount!" do
    
    it "should equal the sum of product_sales, shipping, and coupons" do
      @orders_store = OrdersStore.new
      
      [
        {
          :product_sales => 100.0, 
          :shipping => 10.00, 
          :coupon_total => -30.0, 
          :item_total => 150.0, 
          :expected => 80.0
        },
        {
          :product_sales => 0.0, 
          :shipping => 0.00, 
          :coupon_total => -0.0, 
          :item_total => 0.0, 
          :expected => 0.0
        },
        {
          :product_sales => 100.0, 
          :shipping => 10.00, 
          :coupon_total => -0.0, 
          :item_total => 150.0, 
          :expected => 110.0
        }
      ].each do |scenario|
        @orders_store.stub!(:product_sales).and_return(scenario[:product_sales])
        @orders_store.stub!(:shipping).and_return(scenario[:shipping])
        @orders_store.stub!(:coupons).and_return(scenario[:coupon_total])
        
        @orders_store.send :calculate_total_amount!
        @orders_store.total_amount.should == scenario[:expected]
      end
    end
    
  end
    
  
  describe "#calculate_total_reimbursement!" do
    
    
    it "should set the reimbursement amount for the store" do
      @orders_store = OrdersStore.new
      
      [
        {
          :product_sales => 100.0, 
          :product_reimbursement => 60.0, 
          :shipping => 10.00, 
          :coupon_total => -30.0, 
          :store_coupons => -18.0, 
          :item_total => 80.0, 
          :expected => 52.0
        },
        {
          :product_sales => 0.0, 
          :product_reimbursement => 0.0, 
          :shipping => 0.00, 
          :coupon_total => -0.0, 
          :store_coupons => -0.0, 
          :item_total => 0.0, 
          :expected => 0.0
        },
        {
          :product_sales => 100.0, 
          :product_reimbursement => 80.0, 
          :shipping => 10.00, 
          :coupon_total => -0.0, 
          :store_coupons => 0.0, 
          :item_total => 110.0, 
          :expected => 90.0
        }
      ].each do |scenario|
        @orders_store.stub!(:product_sales).and_return(scenario[:product_sales])
        @orders_store.stub!(:product_reimbursement).and_return(scenario[:product_reimbursement])
        @orders_store.stub!(:shipping).and_return(scenario[:shipping])
        @orders_store.stub!(:coupons).and_return(scenario[:coupon_total])
        @orders_store.stub!(:store_coupons).and_return(scenario[:store_coupons])
        
        @orders_store.send :calculate_total_reimbursement!
        @orders_store.total_reimbursement.should == scenario[:expected]
      end
    end
    
    ###
    # There is a condition that made this fail one time, but I don't know what caused it.
    # I need to check more conditions that bubble up.
    #
    # Integration test
    ###
    it "should equal the sum of product_reimbursement, shipping, and coupons" do
      @order = FactoryGirl.create(:complete_order)
      @orders_store = @order.orders_stores.first
      @orders_store.send :calculate_product_sales!
      @orders_store.send :calculate_product_reimbursement!
      @orders_store.send :calculate_shipping!
      @orders_store.send :calculate_coupons!
      @orders_store.send :calculate_total_amount!
      expected = @orders_store.product_reimbursement + @orders_store.store_coupons + @orders_store.shipping
      @orders_store.send :calculate_total_reimbursement!
      @orders_store.total_reimbursement.should == expected
    end
    
  end
  
end

