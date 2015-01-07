require 'spec_helper'

describe Api::V1::AgenciesController do

  describe "#search" do

    context "when results are available" do
      before do
        @agency = Agency.create!(name: "National Park Service", abbreviation: "NPS", organization_code: "NP00")
      end

      it "should return valid JSON" do
        get :search, :query => 'the nps', :format => 'json'
        response.should be_success
        response.body.should == @agency.to_json(only: [:name, :abbreviation, :organization_code])
      end
    end

    context "when search returns nil or raises an exception" do
      it "should return error string" do
        get :search, :query => 'error', :format => 'json'
        response.should_not be_success
        response.body.should =~ /No matching agency could be found./
      end
    end
  end

end