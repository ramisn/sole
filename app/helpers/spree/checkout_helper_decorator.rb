Spree::CheckoutHelper.module_eval do

  def product_price(product_or_variant, options={})
    options.assert_valid_keys(
      :format_as_currency,
      :show_vat_text,
      :uniform_price
    )    
    options.reverse_merge!(
      :format_as_currency => true,
      :show_vat_text => Spree::Config[:show_price_inc_vat],
      :uniform_price => true
    )
    
    price_shown = options.delete(:uniform_price) ?
      product_or_variant.uniform_price :
      product_or_variant.price

    amount = price_shown
    
    if Spree::Config[:show_price_inc_vat]
      amount += Spree::Calculator::Vat.calculate_tax_on(product_or_variant)
    end
    
    options.delete(:format_as_currency) ?
      format_price(amount, options) :
      amount
  end
  
  def checkout_states
      %w(address delivery payment confirm complete)
  end

  def checkout_labels
      ['Order Information', 'Shipping Options', 'Discounts & Payment', 'Confirm', 'Confirmation', 'Error' ]
  end
  
  def checkout_header(state)
    state_index = checkout_states.index(state) || 5
    checkout_labels[state_index]
  end
  
  def checkout_progress
    states = checkout_states
    labels = checkout_labels
    items = states.map do |state|
#      text = t("order_state.#{state}").titleize
      css_classes = []
      current_index = states.index(@order.state) || 5
      state_index = states.index(state) || 5
      
      label = content_tag("span class='checkout_progress_number'", (state_index + 1).to_s + '. ') + labels[state_index]

      if state_index < current_index
        css_classes << 'completed'
        text = link_to label, checkout_state_path(state)
      else
        text = label
      end

      css_classes << 'next' if state_index == current_index + 1
      css_classes << 'current' if state == @order.state
      css_classes << 'first' if state_index == 0
      css_classes << 'last' if state_index == states.length - 1
      # It'd be nice to have separate classes but combining them with a dash helps out for IE6 which only sees the last class
      content_tag('li', content_tag('span', text), :class => css_classes.join('-')) if state_index < 3 # don't want to see confirmation in the progress bar
    end
    content_tag('ol', raw(items.join("\n")), :class => 'progress-steps', :id => "checkout-step-#{@order.state}")
  end
  
  def item_list(store)
    item_no = 0
    text = ''
    @order.line_items.each do |item| 
      if item.store_id == store.id
        text += content_tag('p', content_tag("span class='item_list_number'", (item_no += 1).to_s + '. ') + item.variant.product.name + ' (Qty: ' + item.quantity.to_s + ')' )
      end
    end
    text.html_safe
  end

  def render_payment_method_radio(method)
    unless method.nil?
      case method.method_type
        when "gateway", "authorizenet"
          render_stuff = image_tag("creditcard.gif", :style => "margin-right:7px; position:relative; top:6px; left:-5px;", :title => method.name)
        when "paypalexpress"
          render_stuff = image_tag("https://www.paypal.com/en_US/i/logo/PayPal_mark_37x23.gif", :style => "margin-right:7px; position:relative; top:5px;", :title => method.name) +
              content_tag(:span, "The safer, easier way to pay.", :style => " position:relative; top:-1px;")
        else
          render_stuff = t(method.name, :scope => :payment_methods, :default => method.name)
      end
    end
    return render_stuff
  end

  def button_checked(payment_method, call_params, order)
    if (call_params[:order].blank? || call_params[:order][:payments_attributes].blank? || call_params[:order][:payments_attributes][0].blank? ||
        call_params[:order][:payments_attributes][0][:payment_method_id].blank?)
      payment_method == order.payment_method
    else
      payment_method.id == call_params[:order][:payments_attributes][0][:payment_method_id].to_i
    end
  end

end
