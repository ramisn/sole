class Curebit
  def self.register_purchase_url(order)
    parameters = {
        v: '0.4',
        "p[order_number]" => order.number,
        "p[order_date]" => order.completed_at.xmlschema,
        "p[email]" => order.email,
        "p[subtotal]" => order.item_total.to_s,
        "p[customer_id]" => order.user_id,
        "p[coupon_code]" => order.coupon_code
    }
    order.line_items.each_with_index { |line_item, index|
      parameters.merge! "p[i][#{index}][product_id]" => line_item.variant_id,
        "p[i][#{index}][price]" => line_item.price.to_s,
        "p[i][#{index}][quantity]" => line_item.quantity
    }

    "https://www.curebit.com/public/soletron/purchases/create.js?#{parameters.to_query}".html_safe
  end
end