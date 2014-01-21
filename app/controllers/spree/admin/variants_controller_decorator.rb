Spree::Admin::VariantsController.class_eval do
  before_filter :load_state
  before_filter :show_flash, :only => [:index]
  before_filter :set_fullsize
  create.before :create_before
  update.before :create_before
  
  layout "merchant"

  def show_flash
    if @updating
      flash[:notice] = t(:edit_message)
    end
  end

  def create_before
    puts "*** CREATE input: (updating = #{@updating}" + params[:variant_data].to_s
    if (!@updating || (params[:check][:dirty] == "1"))
      if @updating
        @product = @product.root_product
      end

      need_clone = @updating
      params[:variant_data].each do |variant_params|
        puts "***** variant params: " + variant_params.to_s

        var_params = variant_params[1]
        if var_params[:skip].to_s == "1"
          next
        end

        case var_params[:status].to_s
        when STATUS[:default]
          next
        when STATUS[:edit]
          productToUse = Spree::Product.find(var_params[:product_id])
          productToUse.variants.update_all "deleted_at" => Time.now    # we will reset all the variant information
        when STATUS[:delete]
          puts "**** deleting #{var_params[:product_id]}"
          product_delete = Spree::Product.find(var_params[:product_id])    # aslepak: test this case!
          if product_delete == product_delete.root_product && !product_delete.products.nil? && !product_delete.products.empty?
            new_root_product = product_delete.products[0]
            product_delete.products.delete new_root_product
            new_root_product.products = product_delete.products
            @product = new_root_product
            product_delete.deleted_at = Time.now
            product_delete.save
          else
            product_delete.root_product.products.where(:id => product_delete).update_all "deleted_at" => Time.now
            product_delete.deleted_at = Time.now
            product_delete.save
          end

          next
        else    # STATUS[:new]
          # the first color combo we encounter will use @product, and it will become the parent for all the ones to follow
          if need_clone
            productClone = @product.clone
            productClone.price = @product.price
            productClone.sale_price = @product.sale_price
            productClone.prototype_id = @product.prototype_id
            productClone.taxons = Array.new(@product.taxons)
            productClone.properties = Array.new(@product.properties)
            productClone.product_id = @product.id     # should really be parent_id...
            productClone.sku = @product.sku
            productClone.tax_category_id = @product.tax_category_id
            if !productClone.save
              invoke_callbacks(:create, :fails)
              respond_with(@variant)
            end

            productToUse = productClone
          else
            productToUse = @product
            need_clone = true
          end
        end

        property = Property.find_by_name(:attribute)
        product_properties = ProductProperty.includes(:property).where("product_id = #{productToUse.id} and property_id = #{property.id}")
        if !product_properties.nil? && !product_properties.empty?
          product_properties[0].value = var_params[:attr]
          product_properties[0].save
        end

        var_params[:per_size_data].each do |skuparams|
          if skuparams[1]["skip"].to_s == "1"
            next
          end

          @variant = Variant.new
          @variant.product_id = productToUse.id
          @variant.on_hand = skuparams[1][:on_hand]
          @variant.sku = var_params[:sku]
          @variant.price = productToUse.price
          @variant.sale_price = productToUse.sale_price
          
          option_values = {"color1" => var_params["Primary Color"], "color2" => var_params["Secondary Color"]}
          if !(skuparams[1]["Size"]).nil?
            option_values.merge!({"size" => skuparams[1]["Size"]})
          end
          option_values.each_value {|id| @variant.option_values << OptionValue.find(id)}

          if @variant.save
            puts "**** New variant #{@variant.sku} saved; name = #{@variant.name}"
          else
            puts "**** New variant #{@variant.sku} not saved!"
            invoke_callbacks(:create, :fails)
            respond_with(@variant)
          end
        end
      end
    end

  end

  def create
    action = @updating ? :update : :create
    puts "***** updating? #{@updating} and dirty? #{params[:check][:dirty] == '1'} for product #{@product.name}"
    @product.get_siblings.each do |product|
      product.add_skus if product.draft?
    end
    if (!@updating || (params[:check][:dirty].to_s == "1"))
      invoke_callbacks(action, :before)
      invoke_callbacks(action, :after)

      resource_desc  = @product.class.model_name.human
      resource_desc += " \"#{@product.name}\"" if @product.respond_to?(:name)
      flash[:notice] = I18n.t(@updating ? :successfully_updated : :successfully_created, :resource => resource_desc)
    end

    puts "**** redirecting to #{location_after_save}"
    respond_with(@variant) do |format|
      format.html { redirect_to location_after_save }
      format.js   { render :layout => false }
    end

  end

  # BUGBUG (aslepak) - change this to use the calls in products_helper!
  def location_after_save
    if params[:check].nil? || params[:check][:action].nil?
      merchant_store_product_images_url(params[:store_id], params[:product_id])
    elsif params[:check][:action] == ACTIONS[:previous]
      main_app.edit_merchant_store_product_url(params[:store_id], params[:product_id])
    elsif params[:check][:action] == ACTIONS[:preview]
      preview_product_url(params[:product_id])
    else
      merchant_store_product_images_url(params[:store_id], params[:product_id])
    end
  end

  protected

  def load_state
    @store = Store.find(params[:store_id])
    @product = Spree::Product.find_by_permalink(params[:product_id])
    @updating = !@product.variants.nil? && !@product.variants.empty?
    @variant = Variant.new

    @form_name = "new_variant"
  end

end