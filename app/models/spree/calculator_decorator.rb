Spree::Calculator.class_eval do
  preference :flat_percent_off, :decimal, :default => 0
  
  #
  # This method determines, which line items should be used in a computation.
  # Currently it checks to see if the calculable is a Promotion, and if so,
  # then it return all line items that are not on sale
  #
  def line_items_for_compute(order, options={})
    if calculable.is_a?(Spree::Promotion)
      line_items = if calculable.product
        order.line_items.joins(:variant).where(:variants => {product_id: calculable.product})
      elsif calculable.store
        order.line_items.where(:store_id => calculable.store)
      else
        order.line_items
      end
      
      if self.is_a?(Spree::Calculator::FreeShipping)
        puts "free shipping"
        line_items
      else
        puts "not free shipping"
        line_items.order('spree_line_items.price DESC').not_on_sale
      end
    else
      puts "all line items"
      order.line_items
    end
  end
  
  #
  # This function takes as arguments:
  #   object: the object you are using to computer
  #   save_value: a lambda that calculates the save value based-on being sent this
  #               calculator and the line item
  #   as options:
  #     linked_object: a class that can take a line_item and quantity argument that will
  #                    used for the second value to be returned
  #     save_test: a lambda that tests whether the line item should generate a value, 
  #                defaults to a lambda returning true
  #     add_false_items_to_current: a lambda that determines whether line items that have save_test
  #                                 return false should be carried over into current_line_items
  #                                 as they could still be used, default to false
  # This function returns two items:
  #   first value is the calculated value
  #   second value is an array of the linked_object class objects, if a linked_object class is supplied
  #
  def compute_line_items(object, save_value, options={})
    linked_object = options[:linked_object] || nil
    save_test = options[:save_test] || lambda{|c,opts={}| true}
    add_false_items_to_current = options[:add_false_items_to_current] || lambda{|c,l| false}
    
    sum = 0
    line_items = line_items_for_compute(object)
    
    #puts "line_items is #{line_items.inspect}"
    
    save_current_line_items = false
    current_line_items = {}
    line_item_bucket = {}
    
    count = 0
    
    line_items.each do |line_item|
      puts "  line item is #{line_item.inspect}"
      puts "    with quantity available #{line_item.quantity_available(self)}"
      line_item.quantity_available(self).times do |i|
        
        value = if save_test.call(self, {count: count})
          save_current_line_items = true
          save_value.call(self, line_item)
        else
          save_current_line_items = false
          0
        end
        
        if linked_object and (save_current_line_items or add_false_items_to_current.call(self, line_item))
          if !current_line_items.has_key?(line_item)
            current_line_items[line_item] = linked_object.new(line_item: line_item, quantity: 1, amount: -value)
          else
            current_line_items[line_item].quantity += 1
            current_line_items[line_item].amount += -value
          end
        end
        
        sum += value
        
        if save_current_line_items
          current_line_items.each do |line_item, lo|
            if line_item_bucket.has_key?(line_item)
              line_item_bucket[line_item].quantity += lo.quantity
              line_item_bucket[line_item].amount += lo.amount
            else
              line_item_bucket[line_item] = lo
            end
          end
          current_line_items = {}
        end
        
        count += 1
      end
    end
    
    return sum, line_item_bucket.collect{|key, value| value}
    
  end
  
end
