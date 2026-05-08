# frozen_string_literal: true

describe Api::V2::SearchesController do
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:search_params) do
    { affiliate: 'nps.gov',
      access_key: 'basic_key',
      format: 'json',
      api_key: 'myawesomekey',
      query: 'api',
      query_not: 'excluded',
      query_or: 'alternative',
      query_quote: 'barack obama',
      filetype: 'pdf',
      filter: '2',
      sort_by: 'date' }
  end
  let(:query_params) do
    { query: 'api',
      query_not: 'excluded',
      query_or: 'alternative',
      query_quote: 'barack obama',
      file_type: 'pdf',
      filter: '2' }
  end

  describe '#blended' do
    context 'when the search options are valid' do
      before do
        allow(Affiliate).to receive(:find_by_name).and_return(affiliate)
        search = instance_double(ApiBlendedSearch, as_json: { foo: 'bar' }, modules: %w[AIDOC NEWS])
        allow(ApiBlendedSearch).to receive(:new).with(hash_including(query_params)).and_return(search)
        allow(search).to receive(:run)
        allow(SearchImpression).to receive(:log).with(search,
                                                      'blended',
                                                      hash_including('query'),
                                                      be_a(ActionDispatch::Request))

        get :blended, params: search_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(response.parsed_body['foo']).to eq('bar')
      end
    end

    context 'when search options contains unrecognized attributes' do
      before { get :blended, params: search_params.merge(audience: 'everyone') }

      it 'drops the attribute from the ApiBlendedSearch object' do
        expect(assigns(:search_options).attributes).not_to include({ audience: 'everyone' })
      end
    end
  end

  describe '#i14y' do
    context 'when the search options are not valid' do
      before do
        get :i14y,
            params: {
              affiliate: 'nps.gov',
              format: 'json',
              query: 'api'
            }
      end

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        errors = response.parsed_body['errors']
        expect(errors).to include('access_key must be present')
      end
    end

    context 'when the search options are valid' do
      let!(:search) { instance_double(ApiSearchElastic, as_json: { foo: 'bar' }, modules: %w[I14Y]) }

      before do
        allow(Affiliate).to receive(:find_by_name).and_return(affiliate)
        allow(ApiSearchElastic).to receive(:new).with(hash_including(query: 'api')).and_return(search)
        allow(search).to receive(:run)
        allow(SearchImpression).to receive(:log).with(search,
                                                      'i14y',
                                                      hash_including('query'),
                                                      be_a(ActionDispatch::Request))

        get :i14y, params: search_params
      end

      it { is_expected.to respond_with :success }

      it 'passes the correct options to its search object' do
        expect(assigns(:search_options).attributes).to include({ access_key: 'basic_key',
                                                                 affiliate: affiliate,
                                                                 enable_highlighting: true,
                                                                 file_type: 'pdf',
                                                                 filter: '2',
                                                                 limit: 20,
                                                                 next_offset_within_limit: true,
                                                                 offset: 0,
                                                                 query: 'api',
                                                                 query_not: 'excluded',
                                                                 query_or: 'alternative',
                                                                 query_quote: 'barack obama',
                                                                 sort_by: 'date' })
      end

      context 'when a sitelimit filter is present' do
        let(:params_with_sitelimit) { search_params.merge(sitelimit: 'nps.gov') }

        before do
          get :i14y, params: params_with_sitelimit
        end

        it { is_expected.to respond_with :success }

        it 'removes the sitelimit filter from search options' do
          expect(assigns(:search_options).attributes).
            not_to include({ sitelimit: 'nps.gov' })
        end

        it 'adds a site_limits search param' do
          expect(ApiSearchElastic).to have_received(:new).
            with(hash_including(site_limits: 'nps.gov'))
        end
      end
    end

    context 'when selecting the search engine' do
      let(:elastic_search) { instance_double(ApiSearchElastic, run: true, as_json: {}, modules: []) }
      let(:opensearch) { instance_double(OpenSearch::ApiEngine, run: true, as_json: {}, modules: []) }

      before do
        allow(Affiliate).to receive(:find_by_name).and_return(affiliate)
        allow(SearchImpression).to receive(:log)
        allow(ApiSearchElastic).to receive(:new).and_return(elastic_search)
        allow(OpenSearch::ApiEngine).to receive(:new).and_return(opensearch)
      end

      context 'when the affiliate uses the default engine' do
        it 'uses ApiSearchElastic' do
          get :i14y, params: search_params
          expect(ApiSearchElastic).to have_received(:new)
        end
      end

      context 'when the affiliate is configured to use opensearch' do
        before do
          affiliate.update!(search_engine: 'opensearch')
        end

        it 'uses OpenSearch::ApiEngine' do
          get :i14y, params: search_params
          expect(OpenSearch::ApiEngine).to have_received(:new)
          expect(ApiSearchElastic).not_to have_received(:new)
        end
      end
    end

    context 'when a routed query term is matched' do
      before do
        allow(RoutedQueryImpressionLogger).to receive(:log).
          with(affiliate, 'moar unclaimed money', an_instance_of(ActionController::TestRequest))

        get :i14y, params: search_params.merge(query: 'moar unclaimed money')
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(response.parsed_body['route_to']).to eq('https://www.usa.gov/unclaimed_money')
      end
    end
  end

  # Per the comment in app/controllers/api/v2/searches_controller.rb, this endpoint is currently unused.
  describe '#docs' do
    let(:docs_params) { search_params.merge({ dc: 1 }) }

    context 'when the search options are not valid' do
      before { get :docs, params: docs_params.except(:dc) }

      it { is_expected.to respond_with :bad_request }

      it 'returns errors in JSON' do
        expect(response.parsed_body['errors']).to eq(['dc must be present'])
      end
    end

    context 'when the search options are valid' do
      let!(:search) { instance_double(ApiSearchElastic, as_json: { foo: 'bar' }, modules: %w[SRCH]) }

      before do
        allow(Affiliate).to receive(:find_by_name).and_return(affiliate)
        allow(ApiSearchElastic).to receive(:new).with(hash_including(query_params)).and_return(search)
        allow(search).to receive(:run)
        allow(SearchImpression).to receive(:log).with(search,
                                                      'docs',
                                                      hash_including('query'),
                                                      be_a(ActionDispatch::Request))

        get :docs, params: docs_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search results' do
        expect(response.parsed_body['foo']).to eq('bar')
      end
    end

    context 'when a routed query term is matched' do
      before do
        allow(RoutedQueryImpressionLogger).to receive(:log).
          with(affiliate, 'moar unclaimed money', an_instance_of(ActionController::TestRequest))

        get :docs, params: docs_params.merge(query: 'moar unclaimed money')
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(response.parsed_body['route_to']).to eq('https://www.usa.gov/unclaimed_money')
      end
    end
  end
end
