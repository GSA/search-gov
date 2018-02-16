require 'spec_helper'

describe ImageSearchesController do
  fixtures :affiliates, :instagram_profiles, :languages
  let(:affiliate) { affiliates(:usagov_affiliate) }

  describe "#index" do
    context "when searching on legacy affiliate and the query is present" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:query) { '<script>thunder & lightning</script>' }
      let(:image_search) { double(LegacyImageSearch, :query => 'thunder & lightning', :modules => [], :diagnostics => {}) }

      before do
        allow(affiliate).to receive(:force_mobile_format?).and_return(false)
        expect(Affiliate).to receive(:find_by_name).with('nps.gov').and_return(affiliate)
        expect(LegacyImageSearch).to receive(:new).with(hash_including(affiliate: affiliate, query: 'thunder & lightning')).and_return(image_search)
        expect(image_search).to receive(:run)
      end

      context "for a live search" do
        before do
          get :index, :affiliate => 'nps.gov', :query => '<script>thunder & lightning</script>'
        end

        it { is_expected.to assign_to(:search).with(image_search) }
        it { is_expected.to assign_to :affiliate }
        it { is_expected.to assign_to(:page_title).with("thunder & lightning - NPS Site Search Results") }
        it { is_expected.to assign_to(:search_params).with(
                        hash_including(affiliate: affiliate.name, query: 'thunder & lightning')) }
        it { is_expected.to render_template 'image_searches/index' }

        it "should render the template" do
          expect(response).to render_template 'image_searches/index'
          expect(response).to render_template 'layouts/searches'
        end
      end

      context "for a staged search" do
        before do
          get :index, :affiliate => 'nps.gov', :query => '<script>thunder & lightning</script>', :staged => "true"
        end

        it { is_expected.to assign_to(:page_title).with("thunder & lightning - NPS Site Search Results") }
      end

      context "via the JSON API" do
        let(:search_results_json) { 'search results json' }
        before do
          expect(image_search).to receive(:to_json).and_return(search_results_json)
          get :index, :affiliate => 'nps.gov', :query => '<script>thunder & lightning</script>', :format => :json
        end

        it { is_expected.to respond_with :success }

        it "should render the results in json" do
          expect(response.content_type). to eq "application/json"
          expect(response.body).to eq(search_results_json)
        end
      end
    end

    context "when searching on legacy affiliate and the query is blank" do
      let(:affiliate) { mock_model(Affiliate, :locale => 'en', force_mobile_format?: false) }
      let(:image_search) { double(LegacyImageSearch, :query => nil, :modules => [], :diagnostics => {}) }

      before do
        expect(Affiliate).to receive(:find_by_name).with('agency100').and_return(affiliate)
        expect(LegacyImageSearch).to receive(:new).with(hash_including(:affiliate => affiliate, :query => '')).and_return(image_search)
        expect(image_search).to receive(:run)
        get :index, :affiliate => "agency100"
      end

      it { is_expected.to respond_with :success }
    end

    context 'when params[:affiliate] is not a string' do
      before { get :index, affiliate: { 'foo' => 'bar' }, query: 'gov' }

      it { is_expected.to redirect_to 'https://www.usa.gov/page-not-found' }
    end

    context "when searching on legacy affiliate via the API" do
      fixtures :image_search_labels
      render_views

      before do
        affiliates(:usagov_affiliate).update_attributes!(force_mobile_format: false)
      end

      context "when searching normally" do
        before do
          get :index, :query => '<script>weather</script>', :format => "json", affiliate: 'usagov'
          @search = assigns[:search]
        end

        it "should set the format to json" do
          expect(response.content_type).to eq("application/json")
        end

        it "should sanitize the query term" do
          expect(@search.query).to eq("weather")
        end

        it "should serialize the results into JSON" do
          expect(response.body).to match(/total/)
          expect(response.body).to match(/startrecord/)
          expect(response.body).to match(/endrecord/)
        end
      end

      context "when some error is returned" do
        before do
          get :index, :query => 'a' * 1001, :format => "json", affiliate: 'usagov'
          @search = assigns[:search]
        end

        it "should serialize an error into JSON" do
          expect(response.body).to match(/error/)
          expect(response.body).to match(/#{I18n.translate :too_long}/)
        end
      end
    end

    context "when searching in mobile mode" do
      before do
        affiliate.instagram_profiles << instagram_profiles(:whitehouse)
        get :index, :query => 'obama', :m => "true", :affiliate => 'usagov'
      end

      it "should show the mobile version of the page" do
        expect(response).to be_success
      end
    end

    context "when searching in desktop mode" do
      before do
        affiliate.instagram_profiles << instagram_profiles(:whitehouse)
        get :index, :query => 'obama', :affiliate => 'usagov'
      end

      it "assigns @page_title" do
        expect(assigns[:page_title]).not_to be_blank
      end
    end

    context 'when query param is nil/missing' do
      before do
        get :index, :affiliate => 'usagov'
      end

      it 'should treat it as an empty string' do
        expect(response).to be_success
      end
    end
  end
end
