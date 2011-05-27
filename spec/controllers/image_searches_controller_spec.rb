require 'spec/spec_helper'

describe ImageSearchesController do

  describe "#index" do
    context "when searching as an affiliate" do
      fixtures :affiliates, :affiliate_templates
      render_views

      before do
        @affiliate = affiliates(:power_affiliate)
        get :index, :affiliate => @affiliate.name, :query => "weather"
        @search = assigns[:search]
        @page_title = assigns[:page_title]
      end


      it { should assign_to :affiliate }
      it { should assign_to :page_title }

      it "should render the template" do
        response.should render_template 'image_searches/affiliate_index'
        response.should render_template 'layouts/affiliate'
      end

      it "should set an affiliate page title" do
        @page_title.should == "Image search results for #{@affiliate.name}: #{@search.query}"
      end

      it "should render the header in the response" do
        response.body.should match(/#{@affiliate.header}/)
      end

      it "should render the footer in the response" do
        response.body.should match(/#{@affiliate.footer}/)
      end

      context "when a scope id is provided do" do
        before do
          get :index, :affiliate => @affiliate.name, :query => 'weather', :scope_id => 'SomeScope'
        end

        it "should set the scope id variable" do
          assigns[:scope_id].should == 'SomeScope'
        end
      end
    end

    context "when searching via the API" do
      render_views

      context "when searching normally" do
        before do
          get :index, :query => 'weather', :format => "json"
          @search = assigns[:search]
        end

        it "should set the format to json" do
          response.content_type.should == "application/json"
        end

        it "should serialize the results into JSON" do
          response.body.should =~ /total/
          response.body.should =~ /startrecord/
          response.body.should =~ /endrecord/
        end
      end

      context "when some error is returned" do
        before do
          get :index, :query => 'a' * 1001, :format => "json"
          @search = assigns[:search]
        end

        it "should serialize an error into JSON" do
          response.body.should =~ /error/
          response.body.should =~ /#{I18n.translate :too_long}/
        end
      end
    end

    context "when searching in mobile mode" do
      before do
        get :index, :query => 'obama', :m => "true"
      end

      it "should show the mobile version of the page" do
        response.should be_success
      end
    end

    context "when searching in desktop mode" do
      before do
        get :index, :query => 'obama'
      end

      it "assigns @page_title" do
        assigns[:page_title].should_not be_blank
      end

    end
  end
end
