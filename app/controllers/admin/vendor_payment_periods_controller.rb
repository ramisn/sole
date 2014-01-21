class Admin::VendorPaymentPeriodsController < Spree::Admin::ResourceController
  
  before_filter :set_fullsize
  
  def index
    @vendor_payment_periods = VendorPaymentPeriod
    
    if !params[:start_month].blank?
      year, month = params[:start_month].split('-')
      @vendor_payment_periods = @vendor_payment_periods.beginning_month(year, month)
    end
    
    if !params[:end_month].blank?
      year, month = params[:end_month].split('-')
      @vendor_payment_periods = @vendor_payment_periods.ending_month(year, month)
    end
    
    if !params[:name].blank?
      @vendor_payment_periods = @vendor_payment_periods.joins(:store => :taxon).where('taxons.name LIKE ?', params[:name]+'%')
    end
    if !params[:state].blank?
      @vendor_payment_periods = @vendor_payment_periods.send params[:state]
    end
    
    @vendor_payment_periods = @vendor_payment_periods.includes([:store]).paginate(params[:page]).per(Spree::Config[:orders_per_page])
  end
  
end
