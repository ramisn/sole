require 'spec_helper'

describe(Store) do
  describe("search") do
    before(:all) do
      @user = FactoryGirl.create(:user)
      @store = FactoryGirl.create(:store, {
        :email => Faker::Internet.email,
        :location => Faker::Address.city,
        :about => Faker::Lorem.sentence,
        :taxon => FactoryGirl.create(:taxon)
      })
      @store.stores_users << StoresUser.create({ # TODO: FactoryGirl
        :store => @store,
        :user => @user
      })
      @store.reload
    end
    
    it "should find nothing on nothing" do
      Store.search!(nil).should == []
    end
    it "should find all on blank" do
      expected = Store.all.map(&:id).sort
      Store.search!('').map(&:id).sort.should == expected
    end
    it "should find nothing on random" do
      Store.search!('foobar-lol').should == []
    end
    it "should find by username" do
      @store.username.should_not be_blank
      
      Store.search!(@store.username).should include(@store)
      Store.search!(@store.username[1..-2]).should include(@store)
      Store.search!(@store.username[1..-2].upcase).should include(@store)
    end
    it "should find by email" do
      @store.email.should_not be_blank
      
      Store.search!(@store.email).should include(@store)
      Store.search!(@store.email[1..-2]).should include(@store)
      Store.search!(@store.email[1..-2].upcase).should include(@store)
    end
    it "should find by location" do
      @store.location.should_not be_blank

      Store.search!(@store.location).should include(@store)
      Store.search!(@store.location[1..-2]).should include(@store)
      Store.search!(@store.location[1..-2].upcase).should include(@store)
    end
    it "should find by about" do
      @store.about.should_not be_blank
      
      Store.search!(@store.about).should include(@store)
      Store.search!(@store.about[1..-2]).should include(@store)
      Store.search!(@store.about[1..-2].upcase).should include(@store)
    end
    it "should find by store user email" do
      @user.email.should_not be_empty
      
      @store.stores_users.should_not be_empty
      @store.stores_users.map(&:user).should include(@user)
      
      Store.search!(@user.email).should include(@store)
      Store.search!(@user.email[1..-2]).should include(@store)
      Store.search!(@user.email[1..-2].upcase).should include(@store)
    end
    it "should find all" do
      keys = [@store.email, @store.about]

      Store.search!(keys.join(" ")).should include(@store)
      Store.search!(keys.map {|k| k[1..-2]}.join(" ")).should include(@store)
    end
    it "should find any" do
      keys = [@store.email, 'rand0m']

      Store.search!(keys.join(" ")).should include(@store)
      Store.search!(keys.map {|k| k[1..-2]}.join(" ")).should include(@store)
      
      keys = ['rand0m', @store.about]

      Store.search!(keys.join(" ")).should include(@store)
      Store.search!(keys.map {|k| k[1..-2]}.join(" ")).should include(@store)
    end
  end
end
