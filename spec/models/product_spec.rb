require 'spec_helper'

describe Spree::Product do
  
  describe "#category_taxon" do
    
    before :each do 
      @product = FactoryGirl.create(:product)
    end
    
    it "should find a category taxon" do
      @product.category_taxon.should_not be_nil
    end
    
    it "should be the taxon with the Categories taxonomy" do
      @product.category_taxon.should == @product.taxons.find_by_taxonomy_id(Spree::Taxonomy.find_by_name('Categories'))
    end
    
  end
  
  describe "#commission_percentage" do
    
    before :each do
      @product = FactoryGirl.create(:product)
    end
    
    it "should access the category_taxon's commission" do
      @product.category_taxon.should_receive(:commission_percentage)
      @product.commission_percentage
    end
    
    it "should find a commission rate" do
      @product.commission_percentage.should_not be_nil
    end
    
  end
  
  describe '#random_marketplace' do
    before(:all) do
      17.times do
        FactoryGirl.create(:published_product)
      end
      @products = Product.random_marketplace
    end

    it 'should have spree products_per_page set' do
      Spree::Config[:products_per_page].should_not be_nil
    end
    it 'should fetch from products gte spree products_per_page' do
      puts Product.presentable.count
      Product.presentable.count.should be >= Spree::Config[:products_per_page]
    end
    it 'should return spree products_per_page products' do
      @products.size.should be == Spree::Config[:products_per_page]
    end
  end
  
  describe '#featured' do
    before(:all) do
      @product = FactoryGirl.create(:published_product)
      @featured = @product.featured
    end

    it 'should contain products' do
      @featured.all? {|featured| puts "featured is #{featured}"; featured.is_a?(Product) }.should be_true
    end
  end
  
  describe '#suggested' do
    describe('basics') do
      before(:all) do
        @product = FactoryGirl.create(:published_product)
        @suggested = @product.suggested(4)
      end

      it 'should contain four products' do
        @suggested.size.should == 4
      end

      it 'should contain products' do
        @suggested.all? {|suggested| suggested.is_a?(Product) }.should be_true
      end
    end
  end
  
  describe '#compare_by_following' do
    before(:all) do
      @user = FactoryGirl.create(:user)
      
      @product1 = FactoryGirl.create(:published_product, :name => '1 2 3')
      @product1.stub!(:store).and_return(FactoryGirl.create(:store))

      @product2 = FactoryGirl.create(:published_product, :name => 'a b c')
      @product2.stub!(:store).and_return(FactoryGirl.create(:store))
      
      @user1 = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      
      @store1 = @product1.store
      @store2 = @product2.store
    end

    it 'should 0 if nil user' do
      ret = Product.compare_by_following(nil, @product1, @product2)
      ret.should == 0
    end
    
    it 'should 0 if none followed' do
      ret = Product.compare_by_following(@user, @product1, @product2)
      ret.should == 0
    end
  end
  
  describe '#compare_by_revelance' do
    before(:all) do
      @product1 = FactoryGirl.create(:published_product, :name => '1 2 3')
      @product2 = FactoryGirl.create(:published_product, :name => 'a b c')
    end
    
    it 'should 0 on no query' do
      ret = Product.compare_by_revelance(nil, @product1, @product2)
      ret.should == 0
    end
    
    it 'should 0 on blank query' do
      ret = Product.compare_by_revelance('', @product1, @product2)
      ret.should == 0
    end
    
    it 'should 0 on no match' do
      ret = Product.compare_by_revelance('no match', @product1, @product2)
      ret.should == 0
    end

    #--
    # irb(main):002:0> 2 <=> 1
    # => 1
    #++
    it 'should 1 on first match' do
      ret = Product.compare_by_revelance('1 4', @product1, @product2)
      ret.should == 1
    end

    #--
    # irb(main):001:0> 1 <=> 2
    # => -1
    #++
    it 'should -1 on second match' do
      ret = Product.compare_by_revelance('a d', @product1, @product2)
      ret.should == -1
    end

    it 'should 0 on equal match' do
      ret = Product.compare_by_revelance('1 a', @product1, @product2)
      ret.should == 0
    end
  end
  
  describe '#calculate_rating!' do
    describe 'basics' do
      before(:all) do
        @product = FactoryGirl.create(:published_product)
      end
      
      it 'should fire' do
        lambda {@product.calculate_rating!}.should_not raise_error
      end
    end
  end
  
  describe 'sale_price' do
    describe 'blank' do
      before(:all) do
        @product = FactoryGirl.create(:published_product, {
          :sale_price => ''
        })
        
        @product.reload
      end
      
      it('should exist') { @product.id.should_not be_nil }
      it('should be valid') { @product.should be_valid }
      it('should not be on sale') { @product.should_not be_sale }
      it('should not be within sale') do
        Product.sale.should_not include(@product)
      end
    end
    
    describe 'eq to price' do
      before(:all) do
        @product = FactoryGirl.build(:published_product, {
          :price => 15,
          :sale_price => 15
        })
      end
      
      it('should be invalid') { @product.should_not be_valid }
    end
    
    describe 'gt price' do
      before(:all) do
        @product = FactoryGirl.build(:published_product, {
          :price => 15,
          :sale_price => 16
        })
      end
      
      it('should be invalid') { @product.should_not be_valid }
    end
    
    describe 'lt price' do
      before(:all) do
        @product = FactoryGirl.build(:published_product, {
          :price => 15,
          :sale_price => 14
        })
      end
      
      it('should be valid') { @product.should be_valid }
    end
  end
  
  describe 'sale_at' do
    describe 'blank' do
      before(:all) { @product = FactoryGirl.build(:published_product) }
      it('should be valid') { @product.should be_valid }
    end
    
    describe 'sale_start_at lt sale_end_at' do
      before(:all) do
        @product = FactoryGirl.build(:published_product, {
          :sale_start_at => 2.days.from_now,
          :sale_end_at => 5.days.from_now
        })
      end
      
      it('should be valid') { @product.should be_valid }
    end
    
    describe 'sale_start_at gt sale_end_at' do
      before(:all) do
        @product = FactoryGirl.build(:published_product, {
          :sale_start_at => 5.days.from_now,
          :sale_end_at => 2.days.from_now
        })
      end
      
      it('should not be valid') { @product.should_not be_valid }
    end
  end
  
  describe 'with sale_price only' do
    before(:all) do
      @product = FactoryGirl.create(:published_product, {
        :price => 35,
        :sale_price => 34
      })
    end
    
    it('should be without sale_at') { @product.should_not be_sale_at }
    it('should be on sale') { @product.should be_sale }
    it('should be within sale') { Product.sale.should include(@product) }
  end
  
  describe 'with sale_price and sale_at ongoing' do
    before(:all) do
      @product = FactoryGirl.create(:published_product, {
        :price => 35,
        :sale_price => 34,
        :sale_start_at => 2.days.ago,
        :sale_end_at => 2.days.from_now
      })
    end
    
    it('should be with sale_at') { @product.should be_sale_at }
    it('should be on sale') { @product.should be_sale }
    it('should be within sale') { Product.sale.should include(@product) }
  end
  
  describe 'with sale_price and sale_at expired' do
    before(:all) do
      @product = FactoryGirl.create(:published_product, {
        :price => 35,
        :sale_price => 34,
        :sale_start_at => 2.days.ago,
        :sale_end_at => 1.day.ago
      })
    end
    
    it('should be with sale_at') { @product.should be_sale_at }
    it('should not be on sale') { @product.should_not be_sale }
    it('should not be within sale') do
      Product.sale.to_a.map(&:id).should_not include(@product.id)
    end
  end
  
  describe '#sale_discount' do
    describe 'with sale_price nil' do
      before(:all) { @product = FactoryGirl.build(:published_product) }
      it('should be zero') { @product.sale_discount.should == 0 }
    end
    
    describe 'with sale_price set' do
      before(:all) do
        @product = FactoryGirl.build(:published_product, {
          :price => 10,
          :sale_price => 8
        })
      end
      
      it('should be calculated correctly') do
        @product.sale_price.should == 8
      end
    end
  end
end
