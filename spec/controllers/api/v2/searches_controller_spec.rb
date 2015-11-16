require 'spec_helper'

describe Api::V2::SearchesController do
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
        get :blended, affiliate: 'usagov', query: 'api', format: 'json'
      end

      it { should respond_with :bad_request }

      it 'returns errors JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['HTTPS is required'])
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

    context 'when the search options are valid' do
      let!(:search) { mock(ApiDocsSearch, as_json: { foo: 'bar'}, modules: %w(AWEB)) }

      before do
        affiliate = mock_model(Affiliate, api_access_key: 'my_key', locale: :en)
        Affiliate.should_receive(:find_by_name).and_return(affiliate)

        ApiDocsSearch.should_receive(:new).and_return(search)
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
  end
end
