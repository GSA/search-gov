require 'spec_helper'

describe Api::V2::SearchesController do
  fixtures :affiliates, :document_collections
  let(:affiliate) { mock_model(Affiliate, api_access_key: 'usagov_key', locale: :en) }
  let(:search_params) do
    { affiliate: 'usagov',
      access_key: 'usagov_key',
      format: 'json',
      api_key: 'myawesomekey',
      query: 'api',
      query_not: 'excluded',
      query_or: 'alternative',
      query_quote: 'barack obama',
      filetype: 'pdf',
      filter: '2'
    }
  end
  let(:query_params) do
    { query: 'api',
      query_not: 'excluded',
      query_or: 'alternative',
      query_quote: 'barack obama',
      file_type: 'pdf',
      filter: '2'
    }
  end

  describe '#blended' do
    before do
      expect(Affiliate).to receive(:find_by_name).and_return(affiliate)
      search = double('search', as_json: { foo: 'bar'}, modules: %w(AIDOC NEWS))
      expect(ApiBlendedSearch).to receive(:new).with(hash_including(query_params)).and_return(search)
      expect(search).to receive(:run)
      expect(SearchImpression).to receive(:log).with(search,
                                                 'blended',
                                                 hash_including('query'),
                                                 be_a_kind_of(ActionDispatch::Request))

      get :blended, search_params
    end

    it { is_expected.to respond_with :success }

    it 'returns search JSON' do
      expect(JSON.parse(response.body)['foo']).to eq('bar')
    end
  end

  describe '#azure' do
    context 'when the search options are not valid' do
      before { get :azure, search_params.except(:api_key) }

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['api_key must be present'])
      end
    end

    context 'when the search options are valid' do
      let!(:search) { double(ApiAzureSearch, as_json: { foo: 'bar'}, modules: %w(AWEB)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'usagov_key', locale: :en)
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(ApiAzureSearch).to receive(:new).with(hash_including(query_params)).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                   'azure',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :azure, search_params.merge({ access_key: 'usagov_key' })
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when the search options are valid and the routed flag is enabled' do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      before do
        routed_query = affiliate.routed_queries.build(url: "http://www.gov.gov/foo.html", description: "testing")
        routed_query.routed_query_keywords.build(keyword: 'foo bar')
        routed_query.save!

        get :azure, search_params.merge({ query: 'foo bar', routed: 'true' })
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end

  describe '#azure_web' do
    context 'when the search options are not valid' do
      before { get :azure, search_params.except(:api_key) }

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['api_key must be present'])
      end
    end

    context 'when the search options are valid' do
      let!(:search) { double(ApiAzureCompositeWebSearch, as_json: { foo: 'bar'}, modules: %w(AZCW)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'usagov_key', locale: :en)
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(ApiAzureCompositeWebSearch).to receive(:new).
          with(hash_including(query_params)).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                   'azure_web',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :azure_web, search_params.merge({ access_key: 'usagov_key' })
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when the search options are valid and the routed flag is enabled' do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      before do
        routed_query = affiliate.routed_queries.build(url: "http://www.gov.gov/foo.html", description: "testing")
        routed_query.routed_query_keywords.build(keyword: 'foo bar')
        routed_query.save!

        get :azure_web, search_params.merge({ query: 'foo bar', routed: 'true' })
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end

  describe '#azure_image' do
    context 'when the search options are not valid' do
      before { get :azure, search_params.except(:api_key) }

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['api_key must be present'])
      end
    end

    context 'when the search options are valid' do
      let!(:search) { double(ApiAzureCompositeImageSearch, as_json: { foo: 'bar'}, modules: %w(AZCI)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'usagov_key', locale: :en)
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(ApiAzureCompositeImageSearch).to receive(:new).
          with(hash_including(query_params)).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                   'azure_image',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :azure_image, search_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when the search options are valid and the routed flag is enabled' do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      before do
        routed_query = affiliate.routed_queries.build(url: "http://www.gov.gov/foo.html", description: "testing")
        routed_query.routed_query_keywords.build(keyword: 'foo bar')
        routed_query.save!

        get :azure_image, search_params.merge({ query: 'foo bar', routed: 'true'})
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end

  describe '#bing' do
    let(:bing_params) { search_params.merge({ sc_access_key: 'secureKey' }) }

    context 'when the search options are not valid' do
      before { get :bing, bing_params.except(:sc_access_key) }

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['hidden_key is required'])
      end
    end

    context 'when the search options are valid' do
      let!(:search) { double(ApiBingSearch, as_json: { foo: 'bar'}, modules: %w(BWEB)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'usagov_key', locale: :en)
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(ApiBingSearch).to receive(:new).
          with(hash_including(query_params)).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                   'bing',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :bing, bing_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when the search options are valid and the routed flag is enabled' do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      before do
        routed_query = affiliate.routed_queries.build(url: "http://www.gov.gov/foo.html", description: "testing")
        routed_query.routed_query_keywords.build(keyword: 'foo bar')
        routed_query.save!

        get :bing, bing_params.merge({ query: 'foo bar', routed: 'true'})
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end

  describe '#gss' do
    let(:gss_params) { search_params.merge({ cx: 'my-cx' }) }

    context 'when the search options are not valid' do
      before do
        get :gss, gss_params.except(:cx, :api_key)
      end

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        errors = JSON.parse(response.body)['errors']
        expect(errors).to include('api_key must be present')
        expect(errors).to include('cx must be present')
      end
    end

    context 'when the search options are valid' do
      let!(:search) { double(ApiGssSearch, as_json: { foo: 'bar'}, modules: %w(GWEB)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'usagov_key', locale: :en)
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(ApiGssSearch).to receive(:new).with(hash_including(:query => 'api')).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                   'gss',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :gss, gss_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when the search options are not valid and the routed flag is enabled' do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      before do
        routed_query = affiliate.routed_queries.build(url: "http://www.gov.gov/foo.html", description: "testing")
        routed_query.routed_query_keywords.build(keyword: 'foo bar')
        routed_query.save!

        get :gss, gss_params.merge({ query: 'foo bar', routed: 'true'})
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end

  describe '#i14y' do
    context 'when the search options are not valid' do
      before do
        get :i14y,
            affiliate: 'usagov',
            format: 'json',
            query: 'api'
      end

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        errors = JSON.parse(response.body)['errors']
        expect(errors).to include('access_key must be present')
      end
    end

    context 'when the search options are valid' do
      let!(:search) { double(ApiI14ySearch, as_json: { foo: 'bar'}, modules: %w(I14Y)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'usagov_key', locale: :en)
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(ApiI14ySearch).to receive(:new).with(hash_including(:query => 'api')).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                   'i14y',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :i14y, search_params
      end

      it { is_expected.to respond_with :success }
    end

    context 'when the search options are not valid and the routed flag is enabled' do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      before do
        routed_query = affiliate.routed_queries.build(url: "http://www.gov.gov/foo.html", description: "testing")
        routed_query.routed_query_keywords.build(keyword: 'foo bar')
        routed_query.save!

        get :i14y, search_params.merge({ query: 'foo bar', routed: 'true'})
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end

  describe '#video' do
    context 'when the search options are not valid' do
      before do
        get :video,
            affiliate: 'usagov',
            format: 'json',
            query: 'api'
      end

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        errors = JSON.parse(response.body)['errors']
        expect(errors).to include('access_key must be present')
      end
    end

    context 'when the search options are valid' do
      let!(:search) { double(ApiVideoSearch, as_json: { foo: 'bar'}, modules: %w(VIDS)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'usagov_key', locale: :en)
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(ApiVideoSearch).to receive(:new).with(hash_including(query_params)).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                   'video',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :video, search_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when the search options are not valid and the routed flag is enabled' do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      before do
        routed_query = affiliate.routed_queries.build(url: "http://www.gov.gov/foo.html", description: "testing")
        routed_query.routed_query_keywords.build(keyword: 'foo bar')
        routed_query.save!

        get :video, search_params.merge({ query: 'foo bar', routed: 'true'})
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end

  describe '#docs' do
    let(:docs_params) { search_params.merge({ dc: 1 }) }

    context 'when the search options are not valid' do
      before { get :docs, docs_params.except(:dc) }
      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['dc must be present'])
      end
    end

    context 'when the search options are valid and the affiliate is using BingV6' do
      let!(:search) { double(ApiBingDocsSearch, as_json: { foo: 'bar'}, modules: %w(BWEB)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'usagov_key', locale: :en, search_engine: 'BingV6')
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(ApiBingDocsSearch).to receive(:new).with(hash_including(query_params)).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                   'docs',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :docs, docs_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when the search options are valid, the affiliate is using BingV6, and the collection is deep' do
      let!(:search) { double(ApiI14ySearch, as_json: { foo: 'bar'}, modules: %w(I14Y)) }
      let!(:document_collection) { double(DocumentCollection, too_deep_for_bing?: true) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'usagov_key', locale: :en, search_engine: 'BingV6')
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(DocumentCollection).to receive(:find).and_return(document_collection)

        expect(ApiI14ySearch).to receive(:new).with(hash_including(query_params)).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                   'docs',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :docs, docs_params
      end

      it { is_expected.to respond_with :success }

      it 'should use I14y' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when the search options are valid and the affiliate is using Google' do
      let!(:search) { double(ApiGoogleDocsSearch, as_json: { foo: 'bar'}, modules: %w(GWEB)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'usagov_key', locale: :en, search_engine: 'Google')
        expect(Affiliate).to receive(:find_by_name).and_return(affiliate)

        expect(ApiGoogleDocsSearch).to receive(:new).with(hash_including(query_params)).and_return(search)
        expect(search).to receive(:run)
        expect(SearchImpression).to receive(:log).with(search,
                                                   'docs',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :docs, docs_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when the search options are valid and the routed flag is enabled' do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      before do
        routed_query = affiliate.routed_queries.build(url: "http://www.gov.gov/foo.html", description: "testing")
        routed_query.routed_query_keywords.build(keyword: 'foo bar')
        routed_query.save!

        get :docs, docs_params.merge({ query: 'foo bar', routed: 'true'})
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end
end
