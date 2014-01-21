require 'spec_helper'
require Rails.root.join('lib/soletron/searcher')

describe(Soletron::Searcher) do
  it "should initialize" do
    lambda {Spree::Config.searcher_class.new({})}.should_not raise_error
  end
  
  describe('associations') do
    describe('master') do
      before(:all) do
        @product = FactoryGirl.create(:published_product)
      end
      it 'should be set' do
        @product.master.should_not be_nil
      end
      it 'should be set in results' do
        searcher = Spree::Config.searcher_class.new({
          :keywords => @product.name,
          :per_page => 1000
        })
        searcher.retrieve_products.each do |product|
          next unless product == @product
        
          product.master.should_not be_nil
        end
      end
    end
  end
  
  describe('attributes') do
    describe('name') do
      before(:all) do
        @product = FactoryGirl.create(:published_product)
      end
      it "should be set" do
        @product.name.should_not be_blank
      end
      it "should be found" do
        searcher = Spree::Config.searcher_class.new({
          :keywords => @product.name,
          :per_page => 1000
        })
        searcher.retrieve_products.map(&:id).should include(@product.id)
      end
      it "should be found ambigously" do
        searcher = Spree::Config.searcher_class.new({
          :keywords => @product.name.upcase[1..-2],
          :per_page => 1000
        })
        searcher.retrieve_products.map(&:id).should include(@product.id)
      end
    end
  
    describe('brand') do
      before(:all) do
        @brand = FactoryGirl.create(:brand)
        @product = FactoryGirl.create(:published_product, :brand => @brand)
      end
      it "should be set" do
        @product.brand.should_not be_nil
        @product.brand.name.should_not be_blank
      end
      it "should be found" do
        searcher = Spree::Config.searcher_class.new({
          :keywords => @brand.name,
          :per_page => 1000
        })
        searcher.retrieve_products.map(&:id).should include(@product.id)
      end
      it "should be found ambigously" do
        searcher = Spree::Config.searcher_class.new({
          :keywords => @brand.name.upcase[1..-2],
          :per_page => 1000
        })
        searcher.retrieve_products.map(&:id).should include(@product.id)
      end
    end
  
    describe('color1') do
      before(:all) do
        @color1 = FactoryGirl.build(:option_type, {
          :name => 'ratherweirdcolor',
          :presentation => 'color1'
        })
        @product = FactoryGirl.create(:published_product, {
          :option_types => [@color1]
        })
      end
      it "should be set" do
        @product.option_types.should be_any
      end
      it "should be found" do
        searcher = Spree::Config.searcher_class.new({
          :keywords => @color1.name,
          :per_page => 1000
        })
        searcher.retrieve_products.map(&:id).should include(@product.id)
      end
      it "should be found ambigously" do
        searcher = Spree::Config.searcher_class.new({
          :keywords => @color1.name.upcase,
          :per_page => 1000
        })
        searcher.retrieve_products.map(&:id).should include(@product.id)
      end
    end
    
    describe('color2') do
      before(:all) do
        @color2 = FactoryGirl.build(:option_type, {
          :name => 'veryweirdcolor',
          :presentation => 'color2'
        })
        @product = FactoryGirl.create(:published_product, {
          :option_types => [@color2]
        })
      end
      it "should be set" do
        @product.option_types.should be_any
      end
      it "should not be found" do
        searcher = Spree::Config.searcher_class.new({
          :keywords => @color2.name,
          :per_page => 1000
        })
        searcher.retrieve_products.map(&:id).should_not include(@product.id)
      end
      it "should not be found ambigously" do
        searcher = Spree::Config.searcher_class.new({
          :keywords => @color2.name.upcase,
          :per_page => 1000
        })
        searcher.retrieve_products.map(&:id).should_not include(@product.id)
      end
    end
    
    describe('category') do
      before(:all) do
        @product = FactoryGirl.create(:published_product)
      end
      it "should be set" do
        @product.category_taxon.should_not be_nil
        @product.category_taxon.name.should_not be_blank
      end
      it "should be found" do
        searcher = Spree::Config.searcher_class.new({
          :keywords => @product.category_taxon.name,
          :per_page => 1000
        })
        searcher.retrieve_products.map(&:id).should include(@product.id)
      end
      it "should be found ambigously" do
        searcher = Spree::Config.searcher_class.new({
          :keywords => @product.category_taxon.name.upcase[1..-2],
          :per_page => 1000
        })
        searcher.retrieve_products.map(&:id).should include(@product.id)
      end
    end
    
    describe('meta_keywords') do
      before(:all) do
        @product = FactoryGirl.create(:published_product)
        
        # Avoid callbacks.
        @product.update_attribute(:meta_keywords, 'foof, foof')
      end
      it "should be set" do
        @product.meta_keywords.should_not be_nil
        @product.meta_keywords.should_not be_blank
      end
      it "should be found" do
        searcher = Spree::Config.searcher_class.new({
          :keywords => @product.category_taxon.name,
          :per_page => 1000
        })
        searcher.retrieve_products.map(&:id).should include(@product.id)
      end
      it "should be found ambigously" do
        searcher = Spree::Config.searcher_class.new({
          :keywords => @product.category_taxon.name.upcase[1..-2],
          :per_page => 1000
        })
        searcher.retrieve_products.map(&:id).should include(@product.id)
      end
    end
  end
  
  describe('keywords') do
    before(:all) do
      @color1 = FactoryGirl.build(:option_type, {
        :name => 'red',
        :presentation => 'color1'
      })
      @product = FactoryGirl.create(:published_product, {
        :option_types => [@color1]
      })
    end
    it 'should find by all' do
      searcher = Spree::Config.searcher_class.new({
        :keywords => [@color1.name, @product.category_taxon.name].join(" "),
        :per_page => 1000
      })
      searcher.retrieve_products.map(&:id).should include(@product.id)
    end
    it 'should find by any' do
      searcher = Spree::Config.searcher_class.new({
        :keywords => [@color1.name, 'random'].join(" "),
        :per_page => 1000
      })
      searcher.retrieve_products.map(&:id).should include(@product.id)
      
      searcher = Spree::Config.searcher_class.new({
        :keywords => ['random', @product.category_taxon.name].join(" "),
        :per_page => 1000
      })
      searcher.retrieve_products.map(&:id).should include(@product.id)
    end
  end

end