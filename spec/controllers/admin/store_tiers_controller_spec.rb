require 'spec_helper'

describe Admin::StoreTiersController do
  
  describe "GET index" do
    
    before :each do
      set_admin(controller)
      @store_tier = FactoryGirl.create(:store_tier)
      get :index, use_route: 'spree'
    end
    
    it "assigns @store_tiers" do
      assigns(:store_tiers).each do |store_tier|
        store_tier.should be_a_kind_of(StoreTier)
      end
    end
    
    it "renders the index template" do
      response.should render_template("index")
    end
  end
  
  describe "GET new" do
    
    before :each do
      set_admin(controller)
      get :new, use_route: 'spree'
    end
    
    it "assigns @store_tier" do
      assigns(:store_tier).should be_a_kind_of(StoreTier)
    end
    
    it "renders the new template" do
      response.should render_template("new")
    end
    
  end
  
  describe "POST create" do
    
    describe "success" do
      
      before :each do
        set_admin(controller)
        post :create, {:store_tier => {:name => 'Tier 1', :discount => 50}, use_route: 'spree'}
      end
      
      it "assigns @store_tier" do
        assigns(:store_tier).should be_a_kind_of(StoreTier)
      end
      
      it "should have no errors on @store_tier" do
        assigns(:store_tier).errors.empty?.should == true
      end
      
      it "should have saved @store_tier" do
        assigns(:store_tier).id.should be_a_kind_of(Fixnum)
      end
      
      it "redirects to the index page" do
        response.should redirect_to("/admin/store_tiers")
      end
      
    end
    
    describe "error - name conflict" do
      
      before :each do
        set_admin(controller)
        @store_tier = FactoryGirl.create(:store_tier)
        post :create, {:store_tier => {:name => @store_tier.name, :discount => 50}, use_route: 'spree'}
      end
      
      it "assigns @store_tier" do
        assigns(:store_tier).should be_a_kind_of(StoreTier)
      end
      
      it "should have errors on @store_tier" do
        assigns(:store_tier).errors.size.should == 1
      end
      
      it "renders the new template" do
        response.should render_template("new")
      end
      
    end
  end
  
  describe "GET edit" do
    
    before :each do
      set_admin(controller)
      @store_tier = FactoryGirl.create(:store_tier)
      get :edit, :id => @store_tier.id, use_route: 'spree'
    end
    
    it "assigns @store_tier" do
      assigns(:store_tier).should == @store_tier
    end
    
    it "renders the edit template" do
      response.should render_template("edit")
    end
    
  end
  
  describe "PUT update" do
    
    describe "success" do
      
      before :each do
        set_admin(controller)
        @store_tier = FactoryGirl.create(:store_tier)
        put :update, {:id => @store_tier.id, :store_tier => {:name => 'Tier 1', :discount => 50}, use_route: 'spree'}
      end
      
      it "assigns @store_tier" do
        assigns(:store_tier).should == @store_tier
      end
      
      it "should have no errors on @store_tier" do
        assigns(:store_tier).errors.empty?.should == true
      end
      
      it "should have saved @store_tier" do
        assigns(:store_tier).id.should be_a_kind_of(Fixnum)
      end
      
      it "redirects to the index page" do
        response.should redirect_to("/admin/store_tiers")
      end
      
    end
    
    describe "error - name conflict" do
      
      before :each do
        set_admin(controller)
        @store_tier_conflicting_with = FactoryGirl.create(:store_tier)
        @store_tier = FactoryGirl.create(:store_tier)
        put :update, {:id => @store_tier.id, :store_tier => {:name => @store_tier_conflicting_with.name, :discount => 50}, use_route: 'spree'}
      end
      
      it "assigns @store_tier" do
        assigns(:store_tier).should == @store_tier
      end
      
      it "should have no errors on @store_tier" do
        assigns(:store_tier).errors.size.should == 1
      end
      
      it "redirects to the index page" do
        response.should render_template("edit")
      end
      
    end
    
  end
  
  describe "DELETE destroy" do
    before :each do
      set_admin(controller)
      @store_tier = FactoryGirl.create(:store_tier)
      delete :destroy, :id => @store_tier.id, use_route: 'spree'
    end
    
    it "assigns @store_tier" do
      assigns(:store_tier).should == @store_tier
    end
    
    it "should have no errors on @store_tier" do
      assigns(:store_tier).errors.empty?.should == true
    end
    
    it "should have saved @store_tier" do
      StoreTier.exists?(assigns(:store_tier)).should  == false
    end
    
    it "redirects to the index page" do
      response.should redirect_to("/admin/store_tiers")
    end
  end
  
end
