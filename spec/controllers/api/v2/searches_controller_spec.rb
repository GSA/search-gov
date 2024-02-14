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
      let!(:search) { instance_double(ApiI14ySearch, as_json: { foo: 'bar' }, modules: %w[I14Y]) }

      before do
        allow(Affiliate).to receive(:find_by_name).and_return(affiliate)
        allow(ApiI14ySearch).to receive(:new).with(hash_including(query: 'api')).and_return(search)
        allow(search).to receive(:run)
        allow(SearchImpression).to receive(:log).with(search,
                                                      'i14y',
                                                      hash_including('query'),
                                                      be_a(ActionDispatch::Request))

        get :i14y, params: search_params
      end

      it { is_expected.to respond_with :success }

      it 'passes the correct options to its ApiI14ySearch object' do
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

      context 'when include_facets is true' do
        let(:params_with_facets) { search_params.merge(include_facets: 'true') }

        it 'passes the include_facets value to its ApiI14ySearch object' do
          get :i14y, params: params_with_facets
          expect(assigns(:search_options).attributes).to include({ include_facets: 'true' })
        end
      end

      context 'when an audience filter is present' do
        let(:params_with_audience) { search_params.merge(audience: 'everyone') }

        it 'passes the audience filter to its ApiI14ySearch object' do
          get :i14y, params: params_with_audience
          expect(assigns(:search_options).attributes).to include({ audience: 'everyone' })
        end
      end

      context 'when a content_type filter is present' do
        let(:params_with_content_type) { search_params.merge(content_type: 'article') }

        it 'passes the content_type filter to its ApiI14ySearch object' do
          get :i14y, params: params_with_content_type
          expect(assigns(:search_options).attributes).to include({ content_type: 'article' })
        end
      end

      context 'when a mime_type filter is present' do
        let(:params_with_mime_type) { search_params.merge(mime_type: 'application/pdf') }

        it 'passes the mime_type filter to its ApiI14ySearch object' do
          get :i14y, params: params_with_mime_type
          expect(assigns(:search_options).attributes).to include({ mime_type: 'application/pdf' })
        end
      end

      context 'when a searchgov_custom filter is present' do
        let(:params_with_searchgov_custom) { search_params.merge(searchgov_custom1: 'customOne, customTwo') }

        it 'passes the searchgov_custom filter to its ApiI14ySearch object' do
          get :i14y, params: params_with_searchgov_custom
          expect(assigns(:search_options).attributes).to include({ searchgov_custom1: 'customOne, customTwo' })
        end
      end

      context 'when a tags filter is present' do
        let(:params_with_tags) { search_params.merge(tags: 'tag from params') }

        it 'passes the tags filter to its ApiI14ySearch object' do
          get :i14y, params: params_with_tags
          expect(assigns(:search_options).attributes).to include({ tags: 'tag from params' })
        end
      end

      context 'when updated date filters are present' do
        let(:params_with_updated_dates) do
          search_params.
            merge(updated_since: '2020-01-01', updated_until: '2022-01-01')
        end

        it 'passes the tags filter to its ApiI14ySearch object' do
          get :i14y, params: params_with_updated_dates
          expect(assigns(:search_options).attributes).
            to include({ since_date: '01/01/2020',
                         until_date: '01/01/2022' })
        end
      end

      context 'when created date filters are present' do
        let(:params_with_created_dates) do
          search_params.
            merge(created_since: '2020-01-01', created_until: '2022-01-01')
        end

        it 'passes the tags filter to its ApiI14ySearch object' do
          get :i14y, params: params_with_created_dates
          expect(assigns(:search_options).attributes).
            to include({ created_since_date: '01/01/2020',
                         created_until_date: '01/01/2022' })
        end
      end

      context 'when a sitelimit filter is present' do
        let(:params_with_sitelimit) { search_params.merge(sitelimit: 'nps.gov') }

        before do
          get :i14y, params: params_with_sitelimit
        end

        it { is_expected.to respond_with :success }

        it 'removes the sitelimit filter from its ApiI4ySearch object' do
          expect(assigns(:search_options).attributes).
            not_to include({ sitelimit: 'nps.gov' })
        end

        it 'adds a site_limits search param to the ApiI14ySearch' do
          expect(ApiI14ySearch).to have_received(:new).
            with(hash_including(site_limits: 'nps.gov'))
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

  describe '#video' do
    context 'when the search options are not valid' do
      before do
        get :video,
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

    context 'when search options contains unrecognized attributes' do
      before { get :video, params: search_params.merge(audience: 'everyone') }

      it 'drops the attribute from the ApiVideoSearch object' do
        expect(assigns(:search_options).attributes).not_to include({ audience: 'everyone' })
      end
    end

    context 'when the search options are valid' do
      let!(:search) { instance_double(ApiVideoSearch, as_json: { foo: 'bar' }, modules: %w[VIDS]) }

      before do
        allow(Affiliate).to receive(:find_by_name).and_return(affiliate)
        allow(ApiVideoSearch).to receive(:new).with(hash_including(query_params)).and_return(search)
        allow(search).to receive(:run)
        allow(SearchImpression).to receive(:log).with(search,
                                                      'video',
                                                      hash_including('query'),
                                                      be_a(ActionDispatch::Request))

        get :video, params: search_params
      end

      it { is_expected.to respond_with :success }

      it 'returns search JSON' do
        expect(response.parsed_body['foo']).to eq('bar')
      end
    end

    context 'when a routed query term is matched' do
      before do
        allow(RoutedQueryImpressionLogger).to receive(:log).
          with(affiliate, 'moar unclaimed money', an_instance_of(ActionController::TestRequest))

        get :video, params: search_params.merge(query: 'moar unclaimed money')
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

    context 'when the search options are valid, the affiliate is using BingV7, and the collection is deep' do
      let!(:search) { instance_double(ApiI14ySearch, as_json: { foo: 'bar' }, modules: %w[I14Y]) }
      let!(:document_collection) { instance_double(DocumentCollection, too_deep_for_bing?: true) }

      before do
        allow(Affiliate).to receive(:find_by_name).and_return(affiliate)
        allow(affiliate).to receive(:search_engine).and_return('BingV7')
        allow(DocumentCollection).to receive(:find).and_return(document_collection)
        allow(ApiI14ySearch).to receive(:new).with(hash_including(query_params)).and_return(search)
        allow(search).to receive(:run)
        allow(SearchImpression).to receive(:log).with(search,
                                                      'docs',
                                                      hash_including('query'),
                                                      be_a(ActionDispatch::Request))

        get :docs, params: docs_params
      end

      it { is_expected.to respond_with :success }

      it 'uses I14y' do
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
