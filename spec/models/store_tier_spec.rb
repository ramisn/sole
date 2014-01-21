require 'spec_helper'

describe StoreTier do
  
  context "shoulda validations" do
    it { should have_many(:stores) }
    subject { FactoryGirl.create(:store_tier) }    
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:discount) }
  end

end
