Spree::Variant.class_eval do
  
  validates :sku, :presence => true, :unless => :is_master
  validate do
    self.errors[:primary_color] = I18n.t(:cant_be_blank, :default => "can't be blank") if self.primary_color.blank? && !self.is_master
    true
  end
  validate do
    return true unless self.product.require_size?
    self.errors[:size] = I18n.t(:cant_be_blank, :default => "can't be blank") if self.size.blank? && !self.is_master
    true
  end
  
  def size_options
    self.option_values.where("name LIKE 'size%'")
  end
  
  def store_id
    # assumes there is only one taxon with a store_id
    self.product.taxons.detect { |taxon| !taxon.store_id.blank? }.store_id 
  rescue
    nil
  end
  
  def primary_color
    color = Spree::OptionType.where(:name => "color1").first
    primary_color = self.option_values.find{|option_value| option_value.option_type_id == color.id}
    primary_color.present? ? primary_color.presentation : nil
  end
  
  def primary_color=(id)
    color = Spree::OptionType.where(:name => "color1").first
    ov = self.option_values.dup.delete_if{|option_value| option_value.option_type_id == color.id}
    if id.present?
      option_value = color.option_values.find(id)
      ov.push(option_value)
    end
    self.option_values = ov
  end

  def secondary_color=(id)
    color = Spree::OptionType.where(:name => "color2").first
    ov = self.option_values.dup.delete_if{|option_value| option_value.option_type_id == color.id}
    if id.present?
      option_value = color.option_values.find(id)
      ov.push(option_value)
    end
    self.option_values = ov
  end

  def secondary_color
    color = Spree::OptionType.where(:name => "color2").first
    secondary_color = self.option_values.find{|option_value| option_value.option_type_id == color.id}
    secondary_color.present? ? secondary_color.presentation : nil
  end
  
  def size
    option_value = self.option_values.find{|option_value| option_value.name.downcase =~ /^size/}
    option_value.present? ? option_value.presentation : nil
  end
  
  def size=(id)
    ov = self.option_values.dup.delete_if{|option_value| option_value.name.downcase =~ /^size/}
    if id.present?
      size = Spree::OptionValue.find(id)
      ov.push(size)
    end
    self.option_values = ov
  end
  
  #def options_text
  #  text = ""
  #  size_option_type_ids
  #  logger.info "**** ids: #{@ids}"
  #  
  #  ###
  #  # Added check for ids, because there could be a case where a size is not set, which the order_spec tests ran into
  #  ###
  #  if @ids
  #    ov = self.option_values.where("option_type_id in #{@ids}")
  #    if !ov.nil? && ov.count > 0
  #      text = "Size: " + ov[0].presentation
  #    end
  #  end
  #  return text.html_safe
  #end

  # For use on upload product page
  def get_size
    option_value = self.option_values.find{|option_value| option_value.name.downcase =~ /^size/}
    option_value.present? ? option_value.id : nil
  end
  
  # For use on upload product page
  def get_primary_color
    color = Spree::OptionType.where(:name => "color1").first
    primary_color = self.option_values.find{|option_value| option_value.option_type_id == color.id}
    primary_color.present? ? primary_color.id : nil
  end
  
  # For use on upload product page
  def get_secondary_color
    color = Spree::OptionType.where(:name => "color2").first
    primary_color = self.option_values.find{|option_value| option_value.option_type_id == color.id}
    primary_color.present? ? primary_color.id : nil
  end
  
  def commission_percentage
    self.product.commission_percentage
  end
  
  # Return true if product is on sale.
  def sale?
    ###
    # Because uniform price only pulls from the master variant, 
    # pull the sale price from the master variant
    ###
    if self.is_master
      return false if self.sale_price.nil?
      return false if self.sale_price.zero?
    else
      return false if self.product.master.sale_price.nil?
      return false if self.product.master.sale_price.zero?
    end
    true
  end
  
  def uniform_price
    if self.is_master
      self.sale? ? self.sale_price : self.price
    else
      self.product.master.uniform_price
    end
  end
  
  protected
  def size_option_type_ids
    return @ids if !@ids.nil?

    size_options = Spree::OptionType.where("name LIKE '%size'")
    if !size_options.nil? and size_options.size > 0 # making sure that there are actually size_options
      ##
      # Moved @ids inside, so that if there were no size_options, it would be nil
      ##
      @ids = ""
      size_options.each do |option|
        @ids += "#{option.id}, "
      end
      @ids = "(#{@ids[0, @ids.length-2]})"
    end
  end
end
