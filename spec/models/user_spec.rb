require 'spec_helper'

describe(Spree::User) do
  describe("search") do
    before(:all) do
      @user = FactoryGirl.create(:user, {
        :current_city => Faker::Address.city,
        :about => Faker::Lorem.sentence
      })
    end
    
    it "should find nothing on nothing" do
      Spree::User.search!(nil).should == []
    end
    it "should find all on blank" do
      expected = Spree::User.all.map(&:id).sort
      Spree::User.search!('').map(&:id).sort.should == expected
    end
    it "should find nothing on random" do
      Spree::User.search!('foobar-lol').should == []
    end
    it "should find by username" do
      @user.username.should_not be_blank
      Spree::User.search!(@user.username).should include(@user)
      Spree::User.search!(@user.username[1..-2]).should include(@user)
      Spree::User.search!(@user.username[1..-2].upcase).should include(@user)
    end
    it "should find by email" do
      @user.email.should_not be_blank
      
      Spree::User.search!(@user.email).should include(@user)
      Spree::User.search!(@user.email[1..-2]).should include(@user)
      Spree::User.search!(@user.email[1..-2].upcase).should include(@user)
    end
    it "should find by current_city" do
      @user.current_city.should_not be_blank
      
      Spree::User.search!(@user.current_city).should include(@user)
      Spree::User.search!(@user.current_city[1..-2]).should include(@user)
      Spree::User.search!(@user.current_city[1..-2].upcase).should include(@user)
    end
    it "should find by about" do
      @user.about.should_not be_blank
      
      Spree::User.search!(@user.about).should include(@user)
      Spree::User.search!(@user.about[1..-2]).should include(@user)
      Spree::User.search!(@user.about[1..-2].upcase).should include(@user)
    end
    it "should find all" do
      keys = [@user.email, @user.current_city]

      Spree::User.search!(keys.join(" ")).should include(@user)
      Spree::User.search!(keys.map {|k| k[1..-2]}.join(" ")).should include(@user)
    end
    it "should find any" do
      keys = [@user.email, 'rand0m']

      Spree::User.search!(keys.join(" ")).should include(@user)
      Spree::User.search!(keys.map {|k| k[1..-2]}.join(" ")).should include(@user)
      
      keys = ['rand0m', @user.about]

      Spree::User.search!(keys.join(" ")).should include(@user)
      Spree::User.search!(keys.map {|k| k[1..-2]}.join(" ")).should include(@user)
    end
  end
end
