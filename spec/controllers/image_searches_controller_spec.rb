require 'spec_helper'

describe ImageSearchesController do
  fixtures :affiliates, :instagram_profiles, :languages
  let(:affiliate) { affiliates(:usagov_affiliate) }

  describe "#index" do
    context "when searching on legacy affiliate and the query is present" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:query) { '<script>thunder & lightning</script>' }
      let(:image_search) { mock(LegacyImageSearch, :query => 'thunder & lightning', :modules => []) }

      before do
        affiliate.stub(:force_mobile_format?).and_return(false)
        Affiliate.should_receive(:find_by_name).with('nps.gov').and_return(affiliate)
        LegacyImageSearch.should_receive(:new).with(hash_including(affiliate: affiliate, query: 'thunder & lightning')).and_return(image_search)
        image_search.should_receive(:run)
      end

      context "for a live search" do
        before do
          get :index, :affiliate => 'nps.gov', :query => '<script>thunder & lightning</script>'
        end

        it { should assign_to(:search).with(image_search) }
        it { should assign_to :affiliate }
        it { should assign_to(:page_title).with("thunder & lightning - NPS Site Search Results") }
        it { should assign_to(:search_params).with(
                        hash_including(affiliate: affiliate.name, query: 'thunder & lightning')) }
        it { should render_template 'image_searches/index' }

        it "should render the template" do
          response.should render_template 'image_searches/index'
          response.should render_template 'layouts/searches'
        end
      end

      context "for a staged search" do
        before do
          get :index, :affiliate => 'nps.gov', :query => '<script>thunder & lightning</script>', :staged => "true"
        end

        it { should assign_to(:page_title).with("thunder & lightning - NPS Site Search Results") }
      end

    end

    context "when searching on legacy affiliate and the query is blank" do
      let(:affiliate) { mock_model(Affiliate, :locale => 'en', force_mobile_format?: false) }
      let(:image_search) { mock(LegacyImageSearch, :query => nil, :modules => []) }

      before do
        Affiliate.should_receive(:find_by_name).with('agency100').and_return(affiliate)
        LegacyImageSearch.should_receive(:new).with(hash_including(:affiliate => affiliate, :query => '')).and_return(image_search)
        image_search.should_receive(:run)
        get :index, :affiliate => "agency100"
      end

      it { should respond_with :success }
    end

    context 'when params[:affiliate] is not a string' do
      before { get :index, affiliate: { 'foo' => 'bar' }, query: 'gov' }

      it { should redirect_to 'http://www.usa.gov/page-not-found' }
    end

    context "when searching in mobile mode" do
      before do
        affiliate.instagram_profiles << instagram_profiles(:whitehouse)
        get :index, :query => 'obama', :m => "true", :affiliate => 'usagov'
      end

      it "should show the mobile version of the page" do
        response.should be_success
      end
    end

    context "when searching in desktop mode" do
      before do
        affiliate.instagram_profiles << instagram_profiles(:whitehouse)
        get :index, :query => 'obama', :affiliate => 'usagov'
      end

      it "assigns @page_title" do
        assigns[:page_title].should_not be_blank
      end
    end

    context 'when query param is nil/missing' do
      before do
        get :index, :affiliate => 'usagov'
      end

      it 'should treat it as an empty string' do
        response.should be_success
      end
    end
  end
end
