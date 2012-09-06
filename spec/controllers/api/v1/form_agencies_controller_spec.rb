require 'spec_helper'

describe Api::V1::FormAgenciesController do
  fixtures :form_agencies
  let(:form_agency) { form_agencies(:en_uscis) }

  describe "#show" do
    context "when the record can be found" do

      it "should return the Form record" do
        get :show, :id => form_agency.id, :format => 'json'
        response.should be_success
        response.body.should == form_agency.to_json(Api::V1::FormAgenciesController::JSON_OPTIONS)
      end
    end

    context "when the record cannot be found" do
      it "should return an error" do
        get :show, :id => 0, :format => 'json'
        response.should_not be_success
        response.body.should =~ /The form agency you were looking for could not be found/
      end
    end
  end

  describe "#index" do
    it "should return all the form agency records as JSON array" do
      get :index, :format => 'json'
      response.should be_success
      response.body.should == "[#{form_agency.to_json(Api::V1::FormAgenciesController::JSON_OPTIONS)}]"
    end
  end
end