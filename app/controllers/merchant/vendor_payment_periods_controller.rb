class Merchant::VendorPaymentPeriodsController < Spree::Admin::ResourceController
  layout 'merchant'
  include Spree::BaseHelper
  include ActionView::Helpers::NumberHelper
  
  before_filter :authorized_store_member?
  before_filter :load_store
  before_filter :set_body_id
  
  def index
    @vendor_payment_periods = @store.vendor_payment_periods.order('vendor_payment_periods.month DESC').includes([:store]).page(params[:page]).per(Spree::Config[:orders_per_page])
  end
  
  def show
    @hide_store_nav = true    
  end
  
  def line_items_data
    respond_to do |format|
      format.csv do
        @line_items = @vendor_payment_period.line_items.order('orders.completed_at ASC')
        csv_data = CSV.generate do |csv|
          csv << [
                  t('order_date'), 
                  t('order_#'), 
                  t('sku'), 
                  t('name'), 
                  t('product_type'),
                  t('category'),
                  t('description'), 
                  t('quantity'), 
                  t('price'), 
                  t('merchant_%'), 
                  t('merchant_amount') 
                ]
          @line_items.each do |line_item|
            csv << [
              line_item.order.completed_at.strftime("%-m/%-d/%Y"),
              line_item.order.number,
              (line_item.variant ? line_item.variant.sku : ''),
              (line_item.variant and line_item.variant.product ? line_item.variant.product.name : ''),
              (line_item.variant and line_item.variant.product ? line_item.variant.product.get_type : ''),
              (line_item.variant and line_item.variant.product ? line_item.variant.product.category_taxon.name : ''),
              (line_item.variant ? variant_options(line_item.variant) : ''),
              line_item.quantity,
              number_to_currency(line_item.price),
              "#{(100 - line_item.commission_percentage)}%",
              number_to_currency(line_item.store_amount)
            ]
          end
        end
        
        render :text => csv_data, :layout => nil
      end
    end
  end
  
  def shipping_data
    respond_to do |format|
      format.csv do
        @shipping_charges = @vendor_payment_period.shipping_charges.order('orders.completed_at ASC')
        csv_data = CSV.generate do |csv|
          csv << [
            t('order_date'), 
            t('order_#'), 
            t('product_reimbursement'), 
            t('#_items'), 
            t('total_shipping'),
            t('shipping_method'),
            t('last_shipping_date'),
            t('shipping_state'),
            t('reference_numbers'),
            t('carriers')
          ]
          @shipping_charges.each do |shipping_charge|
            orders_store = shipping_charge.order.orders_stores.where(:store_id => @vendor_payment_period.store).limit(1).first
            csv << [
              shipping_charge.order.completed_at.strftime("%-m/%-d/%Y"),
              shipping_charge.order.number,
              orders_store.product_reimbursement,
              shipping_charge.order.line_items.sum(:quantity),
              number_to_currency(shipping_charge.amount),
              shipping_charge.source.shipping_method.name,
              (orders_store.shipments.order('shipped_at DESC').first.shipped_at ? orders_store.shipments.order('shipped_at DESC').first.shipped_at.strftime("%m-%d-%Y") : ''),
              orders_store.state,
              orders_store.shipments.collect {|shipment| shipment.tracking }.join(','),
              orders_store.shipments.collect {|shipment| shipment.vendor_shipping_method }.join(',')
            ]
          end
        end

        render :text => csv_data, :layout => nil
      end
    end
  end
  
  def coupons_data
    respond_to do |format|
      format.csv do
        @orders_stores = @vendor_payment_period.orders_stores.coupons_applied.joins(:order).order('orders.completed_at ASC')
        csv_data = str = CSV.generate do |csv|
          csv << [
            t('order_date'), 
            t('order_#'), 
            t('coupon_codes'),
            t('coupon_code_%'),
            t('product_reimbursement'),
            t('coupon_value')
          ]
          @orders_stores.each do |orders_store|
            csv << [
              orders_store.order.completed_at.strftime("%-m/%-d/%Y"),
              orders_store.order.number,
              (orders_store.order.promotion_credits.count > 0 ? orders_store.order.promotion_credits.collect {|pc| pc.source.code if pc.source }.join(",") : ""),
              (orders_store.order.promotion_credits.count > 0 ? orders_store.order.promotion_credits.collect {|pc| pc.source.calculator.preferred_flat_percent if pc.source and pc.source.calculator and pc.source.calculator.respond_to?(:preferred_flat_percent) }.join(",") : ""),
              orders_store.product_reimbursement,
              number_to_currency(orders_store.coupons)
            ]
          end
        end

        render :text => csv_data, :layout => nil
      end
    end
  end
    
  protected

  def load_store
    @store = Store.find(params[:store_id])
  end
  
  def set_body_id
    @body_id = "stores"
  end

  def model_class
    Store
  end
  
end
