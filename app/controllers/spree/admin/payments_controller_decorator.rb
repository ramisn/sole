Spree::Admin::PaymentsController.class_eval do
  
  before_filter :load_payment, :except => [:create, :new, :index, :refunds_payable, :refunds_paid, :new_refund, :create_refund]
  before_filter :load_data, :except => [:refunds_payable, :refunds_paid, :new_refund, :create_refund]
  before_filter :set_fullsize
  
  def refunds_payable
    @orders = Spree::Order.credit_owed.
                    order('completed_at ASC').
                    page(params[:page]).
                    per(Spree::Config[:orders_per_page])
                   
  end
  
  def refunds_paid
    @payments = Payment.refunds.
                        where(:source_type => 'Spree::Payment').
                        order('created_at DESC').
                        page(params[:page]).
                        per(Spree::Config[:orders_per_page])
  end
  
  def new_refund
    @order = Spree::Order.find_by_number!(params[:order_id])
    if @order.outstanding_balance < 0
      @payment = @order.payments.order('created_at ASC').limit(1).first.offsets.build
    else
      redirect_to admin_payments_refunds_payable_path
    end
  end
  
  def create_refund
    @order = Spree::Order.find_by_number!(params[:order_id])
    if @order.outstanding_balance < 0
      @payment = @order.payments.order('created_at ASC').limit(1).first.offsets.create(:order => @order, :source_type => 'Spree::Payment', :amount => @order.outstanding_balance, :state => 'completed')
      if !@payment.errors.empty?
        flash[:error] = "There were errors when trying to save the refund"
        return render :new
      end
      flash[:success] = "Your refund was successfully logged"
    end
    redirect_to refunds_payable_admin_payments_path
  end
  
end

