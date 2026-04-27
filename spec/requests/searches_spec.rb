# frozen_string_literal: true

describe SearchesController do
  let(:affiliate) { affiliates(:basic_affiliate) }

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

end
