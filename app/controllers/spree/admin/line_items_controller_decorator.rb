Spree::Admin::LineItemsController.class_eval do
  include Spree::BaseHelper
  include ActionView::Helpers::NumberHelper
  
  before_filter :set_fullsize
  before_filter :load_order, :except => [:index]
  
  def index
    search = {}
    if params[:search]
      if !params[:search][:created_at_greater_than].blank?
        search[:order_completed_at_greater_than] = Time.zone.parse(params[:search][:created_at_greater_than]).beginning_of_day rescue ""
      end
      
      if !params[:search][:created_at_less_than].blank?
        search[:order_completed_at_less_than] = Time.zone.parse(params[:search][:created_at_less_than]).end_of_day rescue ""
      end
    end
    search[:meta_sort] ='order_completed_at.desc'
    search[:order_completed_at_is_not_null] = true
    @search = Spree::LineItem.metasearch(params[:search])

    @metasearch = Spree::LineItem.metasearch(search)
    respond_to do |format|
      format.html do
        @line_items = @metasearch.paginate(:include  => [{:order => :user}, {:variant => {:product => :taxons}}],
                                     :per_page => Spree::Config[:orders_per_page],
                                     :page     => params[:page])
      end
      format.csv do
        @line_items = @metasearch
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
                  t('commission_%'), 
                  t('commission_before_coupons') 
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
              "#{line_item.commission_percentage}%",
              number_to_currency(line_item.total_amount - line_item.store_amount)
            ]
          end
        end
        
        render :text => csv_data, :layout => nil
      end
    end
  end
  
end

