# frozen_string_literal: true

describe ImageSearchesController do
  fixtures :affiliates, :instagram_profiles, :languages
  let(:affiliate) { affiliates(:usagov_affiliate) }

  describe '#index' do
    context 'when the query is present' do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:query) { '<b>thunder & lightning</b>' }
      let(:image_search) do
        instance_double(ImageSearch,
                        query: 'thunder & lightning',
                        modules: [],
                        diagnostics: {})
      end

      before do
        allow(Affiliate).to receive(:find_by_name).with('nps.gov').and_return(affiliate)
        allow(ImageSearch).to receive(:new).
          with(hash_including(affiliate: affiliate, query: 'thunder & lightning')).
          and_return(image_search)
        allow(image_search).to receive(:run)
        get :index, params: { affiliate: affiliate.name,
                              query: query }
      end

      it { is_expected.to assign_to(:search).with(image_search) }
      it { is_expected.to assign_to :affiliate }
      it do
        is_expected.to assign_to(:page_title).
          with('thunder & lightning - NPS Site Search Results')
      end
      it do
        is_expected.to assign_to(:search_params).
          with(hash_including(affiliate: affiliate.name, query: 'thunder & lightning'))
      end
      it { is_expected.to render_template 'image_searches/index' }

      it 'renders the template' do
        expect(response).to render_template 'image_searches/index'
        expect(response).to render_template 'layouts/searches'
      end

      context 'via the JSON API' do
        let(:search_results_json) { 'search results json' }
        before do
          expect(image_search).to receive(:to_json).and_return(search_results_json)
          get :index,
              params: { affiliate: 'nps.gov',
                        query: query },
              format: :json
        end

        it { is_expected.to respond_with :success }

        it 'renders the results in json' do
          expect(response.content_type). to eq 'application/json'
          expect(response.body).to eq(search_results_json)
        end
      end
    end

    context 'when the query is blank' do
      let(:image_search) do
        instance_double(ImageSearch, query: nil, modules: [], diagnostics: {})
      end

      before do
        expect(ImageSearch).to receive(:new).
          with(hash_including(affiliate: affiliate,
                              query: '')).and_return(image_search)
        expect(image_search).to receive(:run)
        get :index, params: { affiliate: affiliate.name }
      end

      it { is_expected.to respond_with :success }
    end

    context 'when params[:affiliate] is not a string' do
      before { get :index, params: { affiliate: { 'foo': 'bar' }, query: 'gov' } }

      it { is_expected.to redirect_to 'https://www.usa.gov/search-error' }
    end

    context 'when searching via the API' do
      render_views

      context 'when searching normally' do
        before do
          get :index,
              params: { query: '<b>weather</b>',
                        affiliate: 'usagov' },
              format: 'json'
          @search = assigns[:search]
        end

        it 'sets the format to json' do
          expect(response.content_type).to eq('application/json')
        end

        it 'sanitizes the query term' do
          expect(@search.query).to eq('weather')
        end

        it 'serializes the results into JSON' do
          expect(response.body).to match(/total/)
          expect(response.body).to match(/startrecord/)
          expect(response.body).to match(/endrecord/)
        end
      end

      context 'when some error is returned' do
        before do
          get :index, params: { query: '', format: 'json', affiliate: 'usagov' }
          @search = assigns[:search]
        end

        it 'serializes an error into JSON' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['error']).to match(/Please enter a search term/)
        end
      end
    end

    context 'when query param is nil/missing' do
      before do
        get :index, params: { affiliate: 'usagov' }
      end

      it 'treats it as an empty string' do
        expect(response).to be_success
      end
    end
  end
end
