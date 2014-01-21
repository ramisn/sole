require 'spec_helper'

describe(Search) do
  it "should initialize with member" do
    Search.new(:member, nil).kind.should == :member
    Search.new(:member, '').kind.should == :member
    Search.new('member', nil).kind.should == :member
    Search.new('member', '').kind.should == :member
    
    Search.new('member', 'example').kind.should == :member
  end
  it "should initialize with product" do
    Search.new(:product, nil).kind.should == :product
    Search.new(:product, '').kind.should == :product
    Search.new('product', nil).kind.should == :product
    Search.new('product', '').kind.should == :product
    
    Search.new('product', 'example').kind.should == :product
  end
  it "should initialize with store" do
    Search.new(:store, nil).kind.should == :store
    Search.new(:store, '').kind.should == :store
    Search.new('store', nil).kind.should == :store
    Search.new('store', '').kind.should == :store
    
    Search.new('store', 'example').kind.should == :store
  end
  
  describe("member") do
    before(:all) do
      @user = FactoryGirl.create(:user, {
        :current_city => Faker::Address.city,
        :about => Faker::Lorem.sentence
      })
    end
    
    it "should find nothing on nothing" do
      Search.new(:member, nil).results.should == []
    end
    it "should find nothing on random" do
      Search.new(:member, 'random-lol').results.should == []
    end
    it "should find all members" do
      expected = Spree::User.all.map(&:id).sort
      Search.new(:member, '').results.map(&:id).sort.should == expected
    end
    it "should find by email" do
      Search.new(:member, @user.email).results.should == [@user]
    end
  end
  describe("store") do
    before(:all) do
      @store = FactoryGirl.create(:store, {
        :email => Faker::Internet.email,
        :location => Faker::Address.city,
        :about => Faker::Lorem.sentence
      })
    end
    
    it "should find nothing on nothing" do
      Search.new(:store, nil).results.should == []
    end
    it "should find nothing on random" do
      Search.new(:store, 'random-lol').results.should == []
    end
    it "should find all members" do
      expected = Store.all.map(&:id).sort
      Search.new(:store, '').results.map(&:id).sort.should == expected
    end
    it "should find by email" do
      Search.new(:store, @store.email).results.should == [@store]
    end
  end
end