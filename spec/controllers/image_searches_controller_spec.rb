require 'spec_helper'

describe ImageSearchesController do
  fixtures :affiliates
  describe "#index" do
    context "when searching as an affiliate and the query is present" do
      let(:query) { '<script>thunder & lightning</script>' }
      let(:image_search) { mock(ImageSearch, :query => 'thunder & lightning', :modules => []) }

      before do
        @affiliate = affiliates(:basic_affiliate)
        Affiliate.should_receive(:find_by_name).with('agency100').and_return(@affiliate)
        ImageSearch.should_receive(:new).with(hash_including(affiliate: @affiliate, per_page: 20, query: 'thunder & lightning')).and_return(image_search)
        image_search.should_receive(:run)
      end

      context "for a live search" do
        before do
          get :index, :affiliate => "agency100", :query => '<script>thunder & lightning</script>'
        end

        it { should assign_to(:search).with(image_search) }
        it { should assign_to :affiliate }
        it { should assign_to(:page_title).with("thunder & lightning - NPS Site Search Results") }
        it { should assign_to(:search_params).with(
                        hash_including(affiliate: @affiliate.name, query: 'thunder & lightning')) }
        it { should render_template 'image_searches/index' }

        it "should render the template" do
          response.should render_template 'image_searches/index'
          response.should render_template 'layouts/searches'
        end
      end

      context "for a staged search" do
        before do
          get :index, :affiliate => "agency100", :query => '<script>thunder & lightning</script>', :staged => "true"
        end

        it { should assign_to(:page_title).with("thunder & lightning - NPS Site Search Results") }
      end

      context "via the JSON API" do
        let(:search_results_json) { 'search results json' }
        before do
          image_search.should_receive(:to_json).and_return(search_results_json)
          get :index, :affiliate => "agency100", :query => '<script>thunder & lightning</script>', :format => :json
        end

        it { should respond_with_content_type :json }
        it { should respond_with :success }

        it "should render the results in json" do
          response.body.should == search_results_json
        end
      end
    end

    context "when searching as an affiliate and the query is blank" do
      let(:affiliate) { mock_model(Affiliate, :locale => 'en') }
      let(:image_search) { mock(ImageSearch, :query => nil, :modules => []) }

      before do
        Affiliate.should_receive(:find_by_name).with('agency100').and_return(affiliate)
        ImageSearch.should_receive(:new).with(hash_including(:affiliate => affiliate, :query => nil)).and_return(image_search)
        image_search.should_receive(:run)
        get :index, :affiliate => "agency100"
      end

      it { should respond_with :success }
    end

    context 'when params[:affiliate] is not a string' do
      let(:usagov_affiliate) { affiliates(:usagov_affiliate) }
      let(:image_search) { mock(ImageSearch, :query => 'gov', :modules => []) }

      before do
        Affiliate.should_receive(:find_by_name).twice do |arg|
          arg == 'usagov' ? usagov_affiliate : nil
        end
        ImageSearch.should_receive(:new).with(
            hash_including(affiliate: usagov_affiliate,
                           query: 'gov')).
            and_return(image_search)
        image_search.should_receive(:run)
        get :index, affiliate: { 'foo' => 'bar' }, query: 'gov'
      end

      it { should respond_with :success }
    end

    context "when searching via the API" do
      render_views

      context "when searching normally" do
        before do
          get :index, :query => '<script>weather</script>', :format => "json"
          @search = assigns[:search]
        end

        it "should set the format to json" do
          response.content_type.should == "application/json"
        end

        it "should sanitize the query term" do
          @search.query.should == "weather"
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
