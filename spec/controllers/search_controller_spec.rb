require 'spec_helper'

describe(SearchController) do
  describe "no kind" do
    it "should return nothing" do
      set_admin(controller)
      get :index
      response.body.should be_blank
      
      set_admin(controller)
      get :index, :q => ''
      response.body.should be_blank
    end
  end
  
  describe "member" do
    before(:all) do
      @user = FactoryGirl.create(:user, {
        :current_city => Faker::Address.city,
        :about => Faker::Lorem.sentence
      })
    end
    
    it "should find nothing on nothing" do
      set_admin(controller)
      get :index, :kind => "member"
      
      response.should render_template("members/index")
      assigns(:members).should == []
    end
    it "should find nothing on random" do
      set_admin(controller)
      get :index, :kind => "member", :q => 'random-lol'
      
      response.should render_template("members/index")
      assigns(:members).should == []
    end
    it "should find by email" do
      set_admin(controller)
      get :index, {:kind => "member", :q => @user.email[1..-2].upcase}
      
      response.should render_template("members/index")
      assigns(:members).should == [@user]
    end
  end
  
  describe "store" do
    before(:all) do
      @store = FactoryGirl.create(:store, {
        :email => Faker::Internet.email,
        :location => Faker::Address.city,
        :about => Faker::Lorem.sentence
      })
    end
    
    it "should find nothing on nothing" do
      set_admin(controller)
      get :index, :kind => "store"
      
      response.should render_template("stores/index")
      assigns(:stores).should == []
    end
    it "should find nothing on random" do
      set_admin(controller)
      get :index, :kind => "store", :q => 'random-lol'
      
      response.should render_template("stores/index")
      assigns(:stores).should == []
    end
    it "should find by email" do
      set_admin(controller)
      get :index, {:kind => "store", :q => @store.email[1..-2].upcase}
      
      response.should render_template("stores/index")
      assigns(:stores).should == [@store]
    end
  end
end
