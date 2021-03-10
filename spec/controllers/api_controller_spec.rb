require 'spec_helper'

describe ApiController do
  fixtures :affiliates, :users, :site_domains, :features, :whitelisted_v1_api_handles

  describe '#search' do
    let(:affiliate) { affiliates(:basic_affiliate) }

    context 'when the affiliate does not exist' do
      let(:affiliate) { mock_model(Affiliate) }

      before do
        allow(affiliate).to receive_message_chain(:active, :find_by_name).with('missingaffiliate').and_return(nil)
        get :search, params: { affiliate: 'missingaffiliate' }
      end

      it { is_expected.to respond_with :not_found }
    end

    context 'when the affiliate is not on the v1 whitelist' do
      before do
        WhitelistedV1ApiHandle.delete_all
        get :search, params: { affiliate: 'usagov' }
      end

      it { is_expected.to respond_with :not_found }
    end

    context 'when the params[:affiliate] is not a string' do
      before { get :search, params: { affiliate: { 'foo' => 'bar' } } }

      it { is_expected.to respond_with :not_found }
    end

    describe 'with format=json' do
      let(:api_search) { double(ApiSearch, :query => 'pdf', :modules => [], :diagnostics => {}) }

      before do
        json = { result_field: 'result' }.to_json
        expect(ApiSearch).to receive(:new).with(hash_including(affiliate: affiliate, query: 'solar')).and_return(api_search)
        allow(api_search).to receive(:run).and_return(json)
        get :search,
            params: {
              affiliate: affiliate.name,
              format: 'json',
              query: 'solar'
            }
      end

      it { is_expected.to respond_with :success }

      describe 'response body' do
        subject { JSON.parse(response.body) }
        its(['result_field']) { should == 'result' }
      end
    end

    context 'with format=xml' do
      let(:api_search) { double(ApiSearch, :query => 'pdf', :modules => [], :diagnostics => {}) }

      before do
        xml = { result_field: 'result' }.to_xml
        expect(ApiSearch).to receive(:new).with(hash_including(affiliate: affiliate, query: 'solar')).and_return(api_search)
        allow(api_search).to receive(:run).and_return(xml)
        get :search, 
            params: { 
              affiliate: affiliate.name, 
              format:'xml', 
              query: 'solar' 
            }
      end

      it { is_expected.to respond_with :success }

      describe 'response body' do
        subject { Hash.from_xml(response.body)['hash'] }

        its(['result_field']) { should == 'result' }
      end
    end

    context 'with format=html' do
      before do
        get :search, 
        params: { 
          affiliate: affiliate.name, 
          format: :html 
        }
      end

      it { is_expected.to respond_with :not_acceptable }
    end

    describe 'options' do
      before :each do
        @auth_params = { :affiliate => affiliates(:basic_affiliate).name }
      end

      it 'should set the affiliate' do
        get :search, params: @auth_params
        expect(assigns[:search_options][:affiliate]).to eq(affiliates(:basic_affiliate))
      end

      it 'should set the query' do
        get :search, params: @auth_params.merge(:query => 'fish')
        expect(assigns[:search_options][:query]).to eq('fish')
      end

      it 'should set the lat_lon' do
        get :search, params: @auth_params.merge(:query => 'fish', :lat_lon => '37.7676,-122.5164')
        expect(assigns[:search_options][:lat_lon]).to eq('37.7676,-122.5164')
      end
    end

    describe 'logging searches and impressions' do
      let(:api_search) { double(ApiSearch, :query => 'pdf', :modules => [], :run => nil) }

      before do
        expect(ApiSearch).to receive(:new).and_return(api_search)
      end

      context "when it's web" do
        it 'should log the impression with the :web vertical' do
          params = {'affiliate' => affiliate.name, 'query' => 'foo', 'index' => 'web'}
          expect(SearchImpression).to receive(:log).with(api_search, :web, hash_including(params), instance_of(ActionController::TestRequest))
          get :search, params: params
        end
      end

      context "when it's image" do
        it 'should log the impression with the :image vertical' do
          params = {'affiliate' => affiliate.name, 'query' => 'foo', 'index' => 'images'}
          expect(SearchImpression).to receive(:log).with(api_search, :image, hash_including(params), instance_of(ActionController::TestRequest))
          get :search, params: params
        end
      end

      context "when it's news" do
        it 'should log the impression with the :news vertical' do
          params = {'affiliate' => affiliate.name, 'query' => 'foo', 'index' => 'news'}
          expect(SearchImpression).to receive(:log).with(api_search, :news, hash_including(params), instance_of(ActionController::TestRequest))
          get :search, params: params
        end
      end

      context "when it's videonews" do
        it 'should log the impression with the :news vertical' do
          params = {'affiliate' => affiliate.name, 'query' => 'foo', 'index' => 'videonews'}
          expect(SearchImpression).to receive(:log).with(api_search, :news, hash_including(params), instance_of(ActionController::TestRequest))
          get :search, params: params
        end
      end

      context "when it's document collections (docs)" do
        it 'should log the impression with the :docs vertical' do
          params = {'affiliate' => affiliate.name, 'query' => 'foo', 'index' => 'docs'}
          expect(SearchImpression).to receive(:log).with(api_search, :docs, hash_including(params), instance_of(ActionController::TestRequest))
          get :search, params: params
        end
      end

      context "when it's undefined" do
        it 'should log the impression with the :web vertical' do
          params = {'affiliate' => affiliate.name, 'query' => 'foo'}
          expect(SearchImpression).to receive(:log).with(api_search, :web, hash_including(params), instance_of(ActionController::TestRequest))
          get :search, params: params
        end
      end
    end

  end

end
