require 'spec_helper'

describe Api::V2::SearchesController do
  describe '#index' do
    before do
      Affiliate.should_receive(:find_by_name).and_return(mock_model(Affiliate))
      search = mock('search', as_json: { foo: 'bar'}, run: nil)
      ApiBlendedSearch.should_receive(:new).and_return(search)

      get :index, affiliate: 'usagov', query: 'api'
    end

    it { should be_ssl_required }
  end
end
