require 'spec_helper'

describe Spree::Taxon do
  
  describe "#commission_percentage" do
    
    describe "commission rate is set" do
      
      before :each do 
        @taxon = FactoryGirl.create(:category_taxon_with_commission)
      end
      
      it "should return it's commission rate" do
        @taxon.should_receive(:commission_rate)
        @taxon.commission_percentage
      end
      
      it "should have the same commission percentage and rate" do
        @taxon.commission_percentage == @taxon.commission_rate
      end
    end
    
    describe "commission rate is not set" do
      
      before :each do
        @taxon = FactoryGirl.create(:category_taxon_with_parent_with_commission)
      end
      
      it "should check for it's parent" do
        @taxon.should_receive(:parent)
        @taxon.commission_percentage
      end
      
      it "should check it's parent's commission percentage" do
        @taxon.parent.should_receive(:commission_percentage)
        @taxon.commission_percentage
      end
      
      it "should return the parent's commission percentage" do
        @taxon.commission_percentage.should == @taxon.parent.commission_percentage
      end
    end
    
  end
  
end
