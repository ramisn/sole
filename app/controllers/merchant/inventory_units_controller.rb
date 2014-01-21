class Merchant::InventoryUnitsController < Spree::Admin::ResourceController
  
  before_filter :load_objects
  before_filter :authorized_store_member?
  before_filter :require_admin, :only => [:confirm_force_cancel, :force_cancel]
  
  def confirm_cancel
    @jquery_16 = true
  end
  
  def cancel
    if !@inventory_unit.shipped?
      @inventory_unit.cancel!
      @inventory_unit.order.reload
      OrderMailer.cancel_email(@inventory_unit.order).deliver
      flash[:success] = "Item Canceled. One item of #{@inventory_unit.variant.product.name} was canceled from order #{@inventory_unit.order.number}"
    else
      flash[:error] = "You cannot cancel a shipped item"
    end
    redirect_back_or_default edit_merchant_store_order_path(@store, @order)
  end
  
  def confirm_force_cancel
    @jquery_16 = true
  end
  
  def force_cancel
    @inventory_unit.force_cancel!
    OrderMailer.cancel_email(@inventory_unit.order).deliver
    flash[:success] = "Item force canceled."
    redirect_back_or_default edit_merchant_store_order_path(@store, @order)
  end
  
  protected
  
  def load_objects
    unless @inventory_unit
      #puts "problem in inventory units"
      flash[:error] = "The item you were looking for could not be found"
      return redirect_back_or_default account_path
    end
    @store = Store.find(params[:store_id])
    unless (@inventory_unit.variant and @inventory_unit.variant.product and @inventory_unit.variant.product.store == @store) or
            (@inventory_unit.line_item.orders_store.store == @store)
      #puts "store and inventory unit not the same"
      flash[:error] = "You are not authorized to modify that inventory unit"
      return redirect_back_or_default account_path
    end
    #params[:store_id] = @store.id
    @order = @inventory_unit.order
    #puts "loaded all objects"
  end
  
  def require_admin
    unless current_user.admin?
      flash[:error] = "You do not have authorization for that action"
      redirect_back_or_default account_path
    end
  end
end
