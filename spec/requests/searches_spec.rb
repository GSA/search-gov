# frozen_string_literal: true

describe SearchesController do
  let(:affiliate) { affiliates(:basic_affiliate) }

  context '#news' do
    before do
      get '/search/news', params: { query: 'element', affiliate: affiliate.name }
    end

    it 'redirects to /search' do
      expect(response).to redirect_to('/search')
    end
  end

  context '#docs' do
    before do
      get '/search/docs', params: { query: 'pdf',
                                    affiliate: affiliate.name }
    end

    it 'sets the format to html' do
      expect(request.format.to_sym).to eq(:html)
    end

    it 'responds with success' do
      expect(response).to have_http_status(:ok)
    end
  end

  context 'when searching via the legacy video news path' do
    before do
      get '/search/news/videos', params: { query: 'element', affiliate: affiliate.name }
    end

    it 'redirects to /search' do
      expect(response).to redirect_to('/search')
    end
  end
end
