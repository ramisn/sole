require 'spec_helper'

describe(Spree::Admin::ProductsController) do
  before(:each) { set_admin(controller) }
  before(:all) do
    @brand = FactoryGirl.create(:brand)
    @department_id = '2' # Unisex
    @taxon_category = FactoryGirl.create(:category_taxon)
    @taxon_type = FactoryGirl.create(:taxon, :parent => @taxon_category)
    @misc_prototype = FactoryGirl.create(:prototype, :name => 'Misc')
    @store = FactoryGirl.create(:store)
  end
  
  describe('GET new') do
    before(:each) { get(:new, :store_id => @store.id) }
    
    it('success') { response.should be_success }
    it('render') { response.should render_template("admin/products/new") }
  end
  
  describe('POST create') do
    describe('correct') do
      describe('minimum') do
        before(:each) { post(:create, product_params) }
        
        it('redirect') do
          response.should redirect_to(merchant_store_product_variants_path(
            @store.id,
            assigns(:product)
          ))
        end
        
        it('valid') { assigns(:product).should be_valid }
        it('id') { assigns(:product).id.should_not be_nil }
        it('name') { assigns(:product).name.should be_present }
        it('description') do
          assigns(:product).description.should be_present
        end
        it('available_on') do
          assigns(:product).available_on.to_date.should == Time.now.to_date
        end
        it('price') { assigns(:product).price.should_not be_nil }
        it('sale_price') { assigns(:product).sale_price.should be_nil }
        it('sale_end_at') { assigns(:product).sale_end_at.should be_nil }
        it('sale_start_at') { assigns(:product).sale_end_at.should be_nil }
        it('category_taxon') do
          assigns(:product).category_taxon.should == @taxon_category
        end
        it('department') do
          assigns(:product).department.should == 'Unisex'
        end
      end
      
      describe('sale_price') do
        before(:each) do
          p = product_params.tap do |params|
            params[:product].merge!({
              :price => 15,
              :sale_price => 13
            })
          end

          post :create, p
        end
        
        it('valid') { assigns(:product).should be_valid }
        it('id') { assigns(:product).id.should_not be_nil }
        it('price') { assigns(:product).price.should == 15 }
        it('sale_price') { assigns(:product).sale_price.should == 13 }
      end
      
      describe('sale_at') do
        before(:each) do
          p = product_params.tap do |params|
            params[:product].merge!({
              :price => 13,
              :sale_price => 11,
              :sale_start_at => 1.day.from_now.strftime("%Y/%m/%d"),
              :sale_end_at => 2.days.from_now.strftime("%Y/%m/%d")
            })
          end

          post :create, p
        end
        
        it('valid') { assigns(:product).should be_valid }
        it('id') { assigns(:product).id.should_not be_nil }
        it('price') { assigns(:product).price.should == 13 }
        it('sale_price') { assigns(:product).sale_price.should == 11 }
        it('sale_start_at') do
          dejt = 1.day.from_now.to_date
          assigns(:product).sale_start_at.to_date.should == dejt
        end
        it('sale_end_at') do
          dejt = 2.days.from_now.to_date
          assigns(:product).sale_end_at.to_date.should == dejt
        end
      end

      describe('department') do
        describe('men') do
          before(:each) do
            p = product_params.tap do |params|
              params[:department] = '0'
            end

            post :create, p
          end

          it('valid') { assigns(:product).should be_valid }
          it('id') { assigns(:product).id.should_not be_nil }
          it('department') do
            assigns(:product).department.should == "Men's"
          end
        end
      end
    end
    
    describe('incorrect') do
       describe('blank form') do
         before(:each) do          
           post(:create, {
             :store_id => @store.id,
             :product => {
               :name => FactoryGirl.generate(:product_sequence),
               :description => Faker::Lorem.paragraphs(rand(5) + 1).join("\n"),
               :meta_keywords => '',
               :available_on => Time.now.strftime("%Y/%m/%d"),
               :price => (rand(100 * 100) / 100.0).to_s,
               :sale_price => '',
               :sale_end_at => '',
               :sale_start_at => ''
             },
             variant_data: [],
             attachments: [],
             :taxon => {
               :product_category_id => '',
               :product_type_id => '',
               :brand_id => ''
             },
             :custom => 'false',
             use_route: 'spree'
           })
         end

         it('success') { response.should be_success }
         it('render') do
           response.should render_template("admin/products/new")
         end

         it('brand_id error') do
           assigns(:product).errors[:brand_id].should be_any
         end
         it('product_type') do
           assigns(:product).errors[:product_type].should be_any
         end
       end
       
       describe('blank name') do
         before(:each) do
           p = product_params.tap do |params|
             params[:product][:name] = ''
           end

           post :create, p
         end

         it('error') do
           # FIXME
           msg = "can't be blank"
           assigns(:product).errors[:name].should include(msg)
         end
       end
       
       describe('blank department') do
         before(:each) do
           p = product_params.tap do |params|
             params[:department] = nil
           end

           post :create, p
         end

         it('error') do
           # FIXME
           msg = "can't be blank"
           assigns(:product).errors[:product_department].should include(msg)
         end
       end
       
       describe('blank description') do
         before(:each) do
           p = product_params.tap do |params|
             params[:product][:description] = ''
           end

           post :create, p
         end

         it('error') do
           # FIXME
           msg = "can't be blank"
           assigns(:product).errors[:description].should include(msg)
         end
       end
       
       describe('blank brand') do
         before(:each) do
           p = product_params.tap do |params|
             params[:taxon][:brand_id] = ''
           end

           post :create, p
         end

         it('error') do
           # FIXME
           msg = "can't be blank"
           assigns(:product).errors[:brand_id].should include(msg)
         end
       end
       
       describe('blank price') do
         before(:each) do
           p = product_params.tap do |params|
             params[:product][:price] = ''
           end

           post :create, p
         end

         it('error') do
           # FIXME
           msg = "can't be blank"
           assigns(:product).errors[:price].should include(msg)
         end
       end
       
       describe('blank product_category') do
         before(:each) do
           p = product_params.tap do |params|
             params[:taxon][:product_category_id] = ''
           end

           post :create, p
         end

         it('error') do
           # FIXME
           msg = "can't be blank"
           assigns(:product).errors[:product_category].should include(msg)
         end
       end
       
       describe('blank product_type') do
         before(:each) do
           p = product_params.tap do |params|
             params[:taxon][:product_type_id] = ''
           end

           post :create, p
         end

         it('error') do
           # FIXME
           msg = "can't be blank"
           assigns(:product).errors[:product_type].should include(msg)
         end
       end
       
       describe('blank department') do
         before(:each) do
           p = product_params.tap do |params|
             params[:department] = ''
           end

           post :create, p
         end

         it('error') do
           # FIXME
           msg = "can't be blank"
           assigns(:product).errors[:product_department].should include(msg)
         end
       end
       
       describe('incorrect price') do
         before(:each) do
           p = product_params.tap do |params|
             params[:product][:price] = 'XYD'
           end

           post :create, p
         end

         it('error') do
           # FIXME
           msg = "is invalid"
           assigns(:product).errors[:price].should include(msg)
         end
         it('nil') { assigns(:product).price.should be_nil }
       end
     end
   end
   
  protected
    def product_params(params = {})
      # brand was getting deleted between runs, so it was added here
      @brand = FactoryGirl.create(:brand)
      {
        :store_id => @store.id,
        :product => {
          :name => FactoryGirl.generate(:product_sequence),
          :description => Faker::Lorem.paragraphs(rand(5) + 1).join("\n"),
          :meta_keywords => '',
          :available_on => Time.now.strftime("%Y/%m/%d"),
          :price => (rand(100 * 100) / 100.0).to_s,
          :sale_price => '',
          :sale_end_at => '',
          :sale_start_at => ''
        },
        :taxon => {
          :product_category_id => [ @taxon_category.id ],
          :product_type_id => @taxon_type.id,
          :brand_id => @brand.id,
        },
        variant_data: [{
          sku: '123',
          price: (rand(100 * 100) / 100.0).to_s,
        }],
        attachments: [],
        :department => @department_id,
        :custom => 'false',
        use_route: 'spree'
      }.merge(params)
    end
end