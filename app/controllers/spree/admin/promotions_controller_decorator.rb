Spree::Admin::PromotionsController.class_eval do
  before_filter :set_fullsize
  def load_data
    @calculators = [Spree::Calculator::BuyXGetYAtZPercentOff, Spree::Calculator::FlatPercent, Spree::Calculator::FlatRate, Spree::Calculator::FreeShipping, Calculator::FreeItem]
  end

  #
  # Overriding destroy so that it sets promotion to deleted at instead of being destroyed
  #
  def destroy
    invoke_callbacks(:destroy, :before)
    if @object.update_attributes(:deleted_at => Time.now.utc)
      invoke_callbacks(:destroy, :after)
      flash[:notice] = flash_message_for(@object, :successfully_removed)
      respond_with(@object) do |format|
        format.html { redirect_to collection_url }
        format.js   { render :partial => "/admin/shared/destroy" }
      end
    else
      invoke_callbacks(:destroy, :fails)
      respond_with(@object) do |format|
        format.html { redirect_to collection_url }
      end
    end
  end
  
end
