require 'spec/spec_helper'

describe ImageSearchesController do

  describe "#index" do
    context "when searching as an affiliate" do
      let(:affiliate) { mock_model(Affiliate, :name => 'agency100', :display_name => 'Agency Site') }
      let(:image_search) { mock(ImageSearch, :query => 'weather') }

      before do
        Affiliate.should_receive(:find_by_name).with('agency100').and_return(affiliate)
        ImageSearch.should_receive(:new).with(hash_including(:affiliate => affiliate, :query => 'weather')).and_return(image_search)
        image_search.should_receive(:run)
        get :index, :affiliate => "agency100", :query => "weather"
      end


      it { should assign_to(:search).with(image_search) }
      it { should assign_to :affiliate }
      it { should assign_to(:page_title).with("Image search results for Agency Site: weather") }
      it { should render_template 'image_searches/affiliate_index' }

      it "should render the template" do
        response.should render_template 'image_searches/affiliate_index'
        response.should render_template 'layouts/affiliate'
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
