require 'spec_helper'

describe Admin::StoresController do
  
  describe "GET new" do
    
    before :each do
      set_admin(controller)
      get :new, use_route: 'spree'
    end
    
    it "assigns @store_tier" do
      assigns(:store).should be_a_kind_of(Store)
    end
    
    it "renders the new template" do
      response.should render_template("new")
    end
    
  end
  
  describe "POST create" do
    
    describe "success" do
      
      before :each do
        @store_taxonomy = FactoryGirl.create(:store_taxonomy)
        @merchant_role = FactoryGirl.create(:merchant_role)
        @store_tier = FactoryGirl.create(:store_tier)
        @user = FactoryGirl.create(:user)
        set_admin(controller)
        post :create, {:manager => {:email => @user.email}, 
                       :taxon => {:name => 'Tier 1'}, 
                       :brands => {:list => ""},
                       :store => {:store_tier_id => @store_tier.id},
                       use_route: 'spree'}
      end
      
      it "assigns @store" do
        assigns(:store).should be_a_kind_of(Store)
      end
      
      it "should have no errors on @store" do
        assigns(:store).errors.empty?.should == true
      end
      
      it "should have saved @store" do
        assigns(:store).id.should be_a_kind_of(Fixnum)
      end
      
      it "should have saved the link to @store_tier" do
        assigns(:store).store_tier.should == @store_tier
      end
      
      it "redirects to the index page" do
        response.should redirect_to("/admin/stores")
      end
      
    end
    
  end
  
  describe "GET edit" do
    
    before :each do
      set_admin(controller)
      @store = FactoryGirl.create(:store)
      get :edit, :id => @store.id, use_route: 'spree'
    end
    
    it "assigns @store_tier" do
      assigns(:store).should == @store
    end
    
    it "renders the edit template" do
      response.should render_template("edit")
    end
    
  end
  
  describe "PUT update" do
    
    describe "success" do
      
      describe "add a store tier where none existed" do
        
        before :each do
          set_admin(controller)
          @store_tier = FactoryGirl.create(:store_tier)
          @store = FactoryGirl.create(:store)
          put :update, {:id => @store.id, :store => {:store_tier_id => @store_tier.id}, use_route: 'spree'}
        end
        
        it "assigns @store_tier" do
          assigns(:store).should == @store
        end
        
        it "should have no errors on @store_tier" do
          assigns(:store).errors.empty?.should == true
        end
        
        it "should have saved the store tier" do
          assigns(:store).store_tier.should == @store_tier
        end
        
        it "redirects to the index page" do
          response.should redirect_to("/admin/stores")
        end
        
      end
      
      describe "change the store tier" do
        
        before :each do
          set_admin(controller)
          @store_tier = FactoryGirl.create(:store_tier)
          @store_with_tier = FactoryGirl.create(:store)
          put :update, {:id => @store_with_tier.id, :store => {:store_tier_id => @store_tier.id}, use_route: 'spree'}
        end
        
        it "assigns @store_tier" do
          assigns(:store).should == @store_with_tier
        end
        
        it "should have no errors on @store_tier" do
          assigns(:store).errors.empty?.should == true
        end
        
        it "should have saved the store tier" do
          assigns(:store).store_tier.should == @store_tier
        end
        
        it "redirects to the index page" do
          response.should redirect_to("/admin/stores")
        end
        
      end
      
      describe "remove the store tier" do
        
        before :each do
          set_admin(controller)
          @store_with_tier = FactoryGirl.create(:store)
          put :update, {:id => @store_with_tier.id, :store => {:store_tier_id => nil}, use_route: 'spree'}
        end
        
        it "assigns @store_tier" do
          assigns(:store).should == @store_with_tier
        end
        
        it "should have no errors on @store_tier" do
          assigns(:store).errors.empty?.should == true
        end
        
        it "should have saved the store tier" do
          assigns(:store).store_tier.should be_nil
        end
        
        it "redirects to the index page" do
          response.should redirect_to("/admin/stores")
        end
        
      end
      
    end
    
  end
  
end
