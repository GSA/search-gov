require 'spec_helper'

describe Api::V2::SearchesController do
  describe '#index' do
    context 'when request is SSL' do
      before do
        affiliate = mock_model(Affiliate, locale: :en)
        Affiliate.should_receive(:find_by_name).and_return(affiliate)
        search = mock('search', as_json: { foo: 'bar'}, run: nil)
        ApiBlendedSearch.should_receive(:new).and_return(search)

        controller.should_receive(:request_ssl?).and_return(true)
        get :index, affiliate: 'usagov', query: 'api', format: 'json'
      end

      it { should respond_with :success }

      it 'returns search JSON' do
        expect(JSON.parse(response.body)['foo']).to eq('bar')
      end
    end

    context 'when request is not SSL' do
      before do
        controller.should_receive(:request_ssl?).and_return(false)
        get :index, affiliate: 'usagov', query: 'api', format: 'json'
      end

      it { should respond_with :bad_request }

      it 'returns errors JSON' do
        expect(JSON.parse(response.body)['errors']).to eq(['HTTPS is required'])
      end
    end
  end
end
