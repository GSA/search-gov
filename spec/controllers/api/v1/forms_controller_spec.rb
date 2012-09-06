require 'spec_helper'

describe Api::V1::FormsController do
  fixtures :form_agencies
  let(:form_agency) { form_agencies(:en_uscis) }

  describe "#search" do

    context "when query param is missing" do
      it "should pass in a blank string" do
        Form.should_receive(:search_for).with('', hash_including(:file_type => 'PDF')).and_return Struct.new(:results).new([])
        get :search, :file_type => 'PDF', :format => 'json'
        response.should be_success
        response.body.should eql('[]')
      end
    end

    context "when govbox_enabled param is set" do
      it "should convert it to a boolean" do
        Form.should_receive(:search_for).with('', hash_including(:govbox_enabled => false)).and_return Struct.new(:results).new([])
        get :search, :govbox_enabled => 'false', :format => 'json'
      end
    end

    context "when params are present and valid" do

      context "when results are available" do
        before do
          @form1 = Form.create!(:form_agency_id => form_agency.id, :number => 'I-485 Supplement E') do |f|
            f.file_type = 'PDF'
            f.title = 'Instructions for I-485, Supplement E'
            f.description = 'To provide additional instructions for filing of adjustment of status (Form I-485).'
            f.url = 'http://www.uscis.gov/files/form/i-485supe.pdf'
          end
          @form2 = Form.create!(:form_agency_id => form_agency.id, :number => 'I-95') do |f|
            f.file_type = 'PDF'
            f.title = 'I-95 is a highway'
            f.description = 'I-95 is a highway and has nothing to do with Form 485.'
            f.url = 'http://www.uscis.gov/files/form/i-95.pdf'
          end
          Form.reindex
        end

        it "should return valid JSON" do
          get :search, :query => 'form 485', :format => 'json'
          response.should be_success
          response.body.should == "[#{@form1.to_json},#{@form2.to_json}]"
        end
      end

      context "when results are not available" do
        it "should return '[]' empty array string" do
          get :search, :query => 'flsdkjflskdjf', :format => 'json'
          response.should be_success
          response.body.should == '[]'
        end
      end
    end

    context "when Form.search_for returns nil" do
      before do
        Form.stub!(:search_for)
      end

      it "should return '[]' empty array string" do
        get :search, :query => 'error', :format => 'json'
        response.should be_success
        response.body.should == '[]'
      end
    end
  end

  describe "#show" do
    context "when the record can be found" do
      before do
        @form = Form.create!(:form_agency_id => form_agency.id, :number => 'I-485 Supplement E') do |f|
          f.file_type = 'PDF'
          f.title = 'Instructions for I-485, Supplement E'
          f.description = 'To provide additional instructions for filing of adjustment of status (Form I-485).'
          f.url = 'http://www.uscis.gov/files/form/i-485supe.pdf'
        end
      end

      it "should return the Form record" do
        get :show, :id => @form.id, :format => 'json'
        response.should be_success
        response.body.should == @form.to_json
      end
    end

    context "when the record cannot be found" do
      it "should return an error" do
        get :show, :id => 0, :format => 'json'
        response.should_not be_success
        response.body.should =~ /The form you were looking for could not be found/
      end
    end
  end
end