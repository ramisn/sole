Spree::Promotion::Rules::FirstOrder.class_eval do
  
  def eligible?(order)
    ###
    # change this to make it based-on email addresses in all orders
    ###
    if promotion.store
      order.user and OrdersStore.where(:order_id => [order.user.orders.complete]).count == 0
    else
      order.user && order.user.orders.complete.count == 0
    end
  end
  
end
