require 'spec_helper'

describe Spree::Variant do
  describe "#commission_percentage" do
    before :each do
      @variant = FactoryGirl.create(:variant)
    end
    
    it "should find a commission percentage" do
      @variant.commission_percentage.should_not be_nil
    end
    
    it "should access the product's commission" do
      @variant.product.should_receive(:commission_percentage)
      @variant.commission_percentage
    end
  end
  
  describe 'with sale' do
    before(:each) do
      @variant = FactoryGirl.build(:variant, {
        :is_master => true,
        :price => 35,
        :sale_price => 15
      })
    end
    
    it 'should have sale_price set' do
      @variant.sale_price.should == 15
    end
    it 'should be on sale' do
      @variant.should be_sale
    end
    it 'should have uniform_price eq to sale_price' do
      @variant.uniform_price.should == @variant.sale_price
    end
  end
  
  describe 'without sale price' do
    before(:each) do
      @variant = FactoryGirl.build(:variant, {
        :is_master => true,
        :price => 35
      })
    end
    
    it 'should not be on sale' do
      @variant.should_not be_sale
    end
    it 'should have uniform_price eq to price' do
      @variant.uniform_price.should == @variant.price
    end
  end
  
  describe "#sale?" do
    
    it "should return true if the master variant is on sale" do
      @variant = FactoryGirl.build(:variant)
      
      [
        { :is_master => true, :sale_price => 15.00 },
        { :is_master => true, :sale_price => nil },
        { :is_master => true, :sale_price => 0.0 },
        { :is_master => false, :sale_price => 12.00 },
        { :is_master => false, :sale_price => nil },
        { :is_master => false, :sale_price => 0.0 }
      ].each do |variant_set|
        @variant.stub!(:is_master).and_return(variant_set[:is_master])
        if @variant.is_master
          @variant.stub!(:sale_price).and_return(variant_set[:sale_price])
        else
          @variant.product.master.stub!(:sale_price).and_return(variant_set[:sale_price])
        end
        
        @variant.sale?.should == !(variant_set[:sale_price].nil? || variant_set[:sale_price].zero?)
      end
    end
    
  end
end
