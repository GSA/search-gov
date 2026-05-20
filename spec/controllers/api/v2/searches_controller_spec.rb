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
