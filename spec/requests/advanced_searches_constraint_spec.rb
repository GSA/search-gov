# frozen_string_literal: true

describe AdvancedSearchesConstraint do
  before { get '/search/advanced', params: { affiliate: affiliate } }

  context 'when a SearchGov site' do
    let(:affiliate) { affiliates(:searchgov_affiliate).name }

    it 'issues a redirect' do
      expect(response.status).to eq(301)
    end

    it 'redirects to /search' do
      expect(response).to redirect_to("/search?affiliate=#{affiliate}")
    end
  end

  context 'when a BingV7 site' do
    let(:affiliate) { affiliates(:bing_v7_affiliate).name }

    it 'does not issue a redirect' do
      expect(response.status).to eq(200)
    end
  end
end
