require 'spec_helper'

describe Api::V2::SearchesController do
  fixtures :affiliates, :document_collections

  describe '#blended' do
    context 'when request is SSL' do
      include_context 'SSL request'

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'my_key', locale: :en)
        Affiliate.should_receive(:find_by_name).and_return(affiliate)
        search = mock('search', as_json: { foo: 'bar'}, modules: %w(AIDOC NEWS))
        ApiBlendedSearch.should_receive(:new).and_return(search)
        search.should_receive(:run)
        SearchImpression.should_receive(:log).with(search,
                                                   'blended',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :blended, access_key: 'my_key', affiliate: 'usagov', query: 'api', format: 'json'
      end

      it { should respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when request is not SSL' do
      before do
        controller.should_receive(:request_ssl?).and_return(false)
      end

      context 'and the request does not have a search-consumer access key' do
        before do
          get :blended, affiliate: 'usagov', access_key: 'usagov_key', query: 'api', format: 'json'
        end

        it { should respond_with :bad_request }

        it 'returns errors JSON' do
          expect(JSON.parse(response.body)['errors']).to eq(['HTTPS is required'])
        end
      end

      context 'and the request has an invalid search-consumer access key' do
        before do
          get :blended, affiliate: 'usagov', access_key: 'usagov_key', query: 'api', format: 'json', sc_access_key: 'invalidSecureKey'
        end

        it { should respond_with :bad_request }

        it 'returns errors JSON' do
          expect(JSON.parse(response.body)['errors']).to eq(['HTTPS is required'])
        end
      end

      context 'but the request has a valid search-consumer access key' do
        before do
          search = mock('search', as_json: { foo: 'bar'}, modules: %w(AIDOC NEWS))
          ApiBlendedSearch.should_receive(:new).and_return(search)
          search.should_receive(:run)
          search.should_receive(:diagnostics).and_return({})
          get :blended, affiliate: 'usagov', access_key: 'usagov_key', query: 'api', format: 'json', sc_access_key: 'secureKey'
        end

        it { should respond_with :success }

        it 'returns search JSON' do
          expect(JSON.parse(response.body)['foo']).to eq('bar')
        end
      end
    end
  end

  describe '#azure' do
    include_context 'SSL request'

    context 'when the search options are not valid' do
      before do
        get :azure,
            access_key: 'my_key',
            affiliate: 'usagov',
            format: 'json',
            query: 'api'
      end

      it { should respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['api_key must be present'])
      end
    end

    context 'when the search options are valid' do
      let!(:search) { mock(ApiAzureSearch, as_json: { foo: 'bar'}, modules: %w(AWEB)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'my_key', locale: :en)
        Affiliate.should_receive(:find_by_name).and_return(affiliate)

        ApiAzureSearch.should_receive(:new).and_return(search)
        search.should_receive(:run)
        SearchImpression.should_receive(:log).with(search,
                                                   'azure',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :azure,
            access_key: 'my_key',
            affiliate: 'usagov',
            api_key: 'myawesomekey',
            format: 'json',
            query: 'api'
      end

      it { should respond_with :success }

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

        get :azure,
            access_key: 'usagov_key',
            affiliate: 'usagov',
            api_key: 'myawesomekey',
            format: 'json',
            query: 'foo bar',
            routed: 'true'
      end

      it { should respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end

  describe '#azure_web' do
    include_context 'SSL request'

    context 'when the search options are not valid' do
      before do
        get :azure_web,
            access_key: 'my_key',
            affiliate: 'usagov',
            format: 'json',
            query: 'api'
      end

      it { should respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['api_key must be present'])
      end
    end

    context 'when the search options are valid' do
      let!(:search) { mock(ApiAzureCompositeWebSearch, as_json: { foo: 'bar'}, modules: %w(AZCW)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'my_key', locale: :en)
        Affiliate.should_receive(:find_by_name).and_return(affiliate)

        ApiAzureCompositeWebSearch.should_receive(:new).and_return(search)
        search.should_receive(:run)
        SearchImpression.should_receive(:log).with(search,
                                                   'azure_web',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :azure_web,
            access_key: 'my_key',
            affiliate: 'usagov',
            api_key: 'myawesomekey',
            format: 'json',
            query: 'api'
      end

      it { should respond_with :success }

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

        get :azure_web,
            access_key: 'usagov_key',
            affiliate: 'usagov',
            api_key: 'myawesomekey',
            format: 'json',
            query: 'foo bar',
            routed: 'true'
      end

      it { should respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end

  describe '#azure_image' do
    include_context 'SSL request'

    context 'when the search options are not valid' do
      before do
        get :azure_image,
            access_key: 'my_key',
            affiliate: 'usagov',
            format: 'json',
            query: 'api'
      end

      it { should respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['api_key must be present'])
      end
    end

    context 'when the search options are valid' do
      let!(:search) { mock(ApiAzureCompositeImageSearch, as_json: { foo: 'bar'}, modules: %w(AZCI)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'my_key', locale: :en)
        Affiliate.should_receive(:find_by_name).and_return(affiliate)

        ApiAzureCompositeImageSearch.should_receive(:new).and_return(search)
        search.should_receive(:run)
        SearchImpression.should_receive(:log).with(search,
                                                   'azure_image',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :azure_image,
            access_key: 'my_key',
            affiliate: 'usagov',
            api_key: 'myawesomekey',
            format: 'json',
            query: 'api'
      end

      it { should respond_with :success }

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

        get :azure_image,
            access_key: 'usagov_key',
            affiliate: 'usagov',
            api_key: 'myawesomekey',
            format: 'json',
            query: 'foo bar',
            routed: 'true'
      end

      it { should respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end

  describe '#bing' do
    include_context 'SSL request'

    context 'when the search options are not valid' do
      before do
        get :bing,
            access_key: 'my_key',
            affiliate: 'usagov',
            format: 'json',
            query: 'api'
      end

      it { should respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['hidden_key is required'])
      end
    end

    context 'when the search options are valid' do
      let!(:search) { mock(ApiBingSearch, as_json: { foo: 'bar'}, modules: %w(BWEB)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'my_key', locale: :en)
        Affiliate.should_receive(:find_by_name).and_return(affiliate)

        ApiBingSearch.should_receive(:new).and_return(search)
        search.should_receive(:run)
        SearchImpression.should_receive(:log).with(search,
                                                   'bing',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :bing,
            access_key: 'my_key',
            affiliate: 'usagov',
            format: 'json',
            query: 'api',
            sc_access_key: 'secureKey'
      end

      it { should respond_with :success }

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

        get :bing,
            access_key: 'usagov_key',
            affiliate: 'usagov',
            format: 'json',
            query: 'foo bar',
            sc_access_key: 'secureKey',
            routed: 'true'
      end

      it { should respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end

  describe '#gss' do
    include_context 'SSL request'

    context 'when the search options are not valid' do
      before do
        get :gss,
            access_key: 'my_key',
            affiliate: 'usagov',
            format: 'json',
            query: 'api'
      end

      it { should respond_with :bad_request }

      it 'returns errors in JSON' do
        errors = JSON.parse(response.body)['errors']
        expect(errors).to include('api_key must be present')
        expect(errors).to include('cx must be present')
      end
    end

    context 'when the search options are valid' do
      let!(:search) { mock(ApiGssSearch, as_json: { foo: 'bar'}, modules: %w(GWEB)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'my_key', locale: :en)
        Affiliate.should_receive(:find_by_name).and_return(affiliate)

        ApiGssSearch.should_receive(:new).and_return(search)
        search.should_receive(:run)
        SearchImpression.should_receive(:log).with(search,
                                                   'gss',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :gss,
            access_key: 'my_key',
            affiliate: 'usagov',
            api_key: 'myawesomekey',
            cx:  'my-cx',
            format: 'json',
            query: 'api'
      end

      it { should respond_with :success }

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

        get :gss,
            access_key: 'usagov_key',
            affiliate: 'usagov',
            api_key: 'myawesomekey',
            cx:  'my-cx',
            format: 'json',
            query: 'foo bar',
            routed: 'true'
      end

      it { should respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end

  describe '#i14y' do
    include_context 'SSL request'

    context 'when the search options are not valid' do
      before do
        get :i14y,
            affiliate: 'usagov',
            format: 'json',
            query: 'api'
      end

      it { should respond_with :bad_request }

      it 'returns errors in JSON' do
        errors = JSON.parse(response.body)['errors']
        expect(errors).to include('access_key must be present')
      end
    end

    context 'when the search options are valid' do
      let!(:search) { mock(ApiI14ySearch, as_json: { foo: 'bar'}, modules: %w(I14Y)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'my_key', locale: :en)
        Affiliate.should_receive(:find_by_name).and_return(affiliate)

        ApiI14ySearch.should_receive(:new).and_return(search)
        search.should_receive(:run)
        SearchImpression.should_receive(:log).with(search,
                                                   'i14y',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :i14y,
            access_key: 'my_key',
            affiliate: 'usagov',
            format: 'json',
            query: 'api'
      end

      it { should respond_with :success }
    end

    context 'when the search options are not valid and the routed flag is enabled' do
      let(:affiliate) { affiliates(:usagov_affiliate) }

      before do
        routed_query = affiliate.routed_queries.build(url: "http://www.gov.gov/foo.html", description: "testing")
        routed_query.routed_query_keywords.build(keyword: 'foo bar')
        routed_query.save!

        get :i14y,
            access_key: 'usagov_key',
            affiliate: 'usagov',
            format: 'json',
            query: 'foo bar',
            routed: 'true'
      end

      it { should respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end

  describe '#video' do
    include_context 'SSL request'

    context 'when the search options are not valid' do
      before do
        get :video,
            affiliate: 'usagov',
            format: 'json',
            query: 'api'
      end

      it { should respond_with :bad_request }

      it 'returns errors in JSON' do
        errors = JSON.parse(response.body)['errors']
        expect(errors).to include('access_key must be present')
      end
    end

    context 'when the search options are valid' do
      let!(:search) { mock(ApiVideoSearch, as_json: { foo: 'bar'}, modules: %w(VIDS)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'my_key', locale: :en)
        Affiliate.should_receive(:find_by_name).and_return(affiliate)

        ApiVideoSearch.should_receive(:new).and_return(search)
        search.should_receive(:run)
        SearchImpression.should_receive(:log).with(search,
                                                   'video',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :video,
            access_key: 'my_key',
            affiliate: 'usagov',
            format: 'json',
            query: 'api'
      end

      it { should respond_with :success }

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

        get :video,
            access_key: 'usagov_key',
            affiliate: 'usagov',
            format: 'json',
            query: 'foo bar',
            routed: 'true'
      end

      it { should respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end

  describe '#docs' do
    include_context 'SSL request'

    context 'when the search options are not valid' do
      before do
        get :docs,
            access_key: 'my_key',
            affiliate: 'usagov',
            api_key: 'myawesomekey',
            format: 'json',
            query: 'api'
      end

      it { should respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['dc must be present'])
      end
    end

    context 'when the search options are valid and the affiliate is using Bing' do
      let!(:search) { mock(ApiBingDocsSearch, as_json: { foo: 'bar'}, modules: %w(BWEB)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'my_key', locale: :en, search_engine: 'Bing')
        Affiliate.should_receive(:find_by_name).and_return(affiliate)

        ApiBingDocsSearch.should_receive(:new).and_return(search)
        search.should_receive(:run)
        SearchImpression.should_receive(:log).with(search,
                                                   'docs',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :docs,
            access_key: 'my_key',
            affiliate: 'usagov',
            api_key: 'myawesomekey',
            dc: 1,
            format: 'json',
            query: 'api'
      end

      it { should respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when the search options are valid, the affiliate is using Bing, and the collection is deep' do
      let!(:search) { mock(ApiGoogleDocsSearch, as_json: { foo: 'bar'}, modules: %w(GWEB)) }
      let!(:document_collection) { mock(DocumentCollection, too_deep_for_bing?: true) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'my_key', locale: :en, search_engine: 'Bing')
        Affiliate.should_receive(:find_by_name).and_return(affiliate)

        DocumentCollection.should_receive(:find).and_return(document_collection)

        ApiGoogleDocsSearch.should_receive(:new).and_return(search)
        search.should_receive(:run)
        SearchImpression.should_receive(:log).with(search,
                                                   'docs',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :docs,
            access_key: 'my_key',
            affiliate: 'usagov',
            api_key: 'myawesomekey',
            dc: 1,
            format: 'json',
            query: 'api'
      end

      it { should respond_with :success }

      it 'should use Google' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when the search options are valid and the affiliate is using Google' do
      let!(:search) { mock(ApiGoogleDocsSearch, as_json: { foo: 'bar'}, modules: %w(GWEB)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'my_key', locale: :en, search_engine: 'Google')
        Affiliate.should_receive(:find_by_name).and_return(affiliate)

        ApiGoogleDocsSearch.should_receive(:new).and_return(search)
        search.should_receive(:run)
        SearchImpression.should_receive(:log).with(search,
                                                   'docs',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :docs,
            access_key: 'my_key',
            affiliate: 'usagov',
            api_key: 'myawesomekey',
            dc: 1,
            format: 'json',
            query: 'api'
      end

      it { should respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when the search options are valid and the affiliate is using Azure' do
      let!(:search) { mock(ApiAzureDocsSearch, as_json: { foo: 'bar'}, modules: %w(AWEB)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'my_key', locale: :en, search_engine: 'Azure')
        Affiliate.should_receive(:find_by_name).and_return(affiliate)

        ApiAzureDocsSearch.should_receive(:new).and_return(search)
        search.should_receive(:run)
        SearchImpression.should_receive(:log).with(search,
                                                   'docs',
                                                   hash_including('query'),
                                                   be_a_kind_of(ActionDispatch::Request))

        get :docs,
            access_key: 'my_key',
            affiliate: 'usagov',
            api_key: 'myawesomekey',
            dc: 1,
            format: 'json',
            query: 'api'
      end

      it { should respond_with :success }

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

        get :docs,
            access_key: 'usagov_key',
            affiliate: 'usagov',
            dc: 1,
            format: 'json',
            query: 'foo bar',
            routed: 'true'
      end

      it { should respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['redirect']).to eq('http://www.gov.gov/foo.html')
      end
    end
  end
end
