class Merchant::VendorPaymentsController < Spree::Admin::ResourceController
  layout 'merchant'
  before_filter :authorized_store_member?
  before_filter :load_store
  before_filter :set_body_id
  
  def index
    @vendor_payments = VendorPayment.includes(:vendor_payment_period).
                                     where(:vendor_payment_periods => {:store_id => @store}).includes({:vendor_payment_period => :store}).page(params[:page]).per(Spree::Config[:orders_per_page])
                                    
  end
  
  protected

  def load_store
    @store = Store.find(params[:store_id])
  end
  
  def set_body_id
    @body_id = "stores"
  end
  
end
