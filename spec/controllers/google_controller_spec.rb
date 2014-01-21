require 'spec_helper'

describe GoogleController do

  describe "GET 'us_products'" do
    it "returns http success" do
      get 'us_products'
      response.should be_success
    end
  end

end
