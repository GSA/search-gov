# frozen_string_literal: true

describe AdvancedSearchesConstraint do
  before { get '/search/advanced', params: { affiliate: affiliate } }

  context 'when a SearchGov site' do
    let(:affiliate) { affiliates(:searchgov_affiliate).name }

    it 'issues a redirect' do
      expect(response).to have_http_status(:moved_permanently)
    end

    it { is_expected.to redirect_to("/search?affiliate=#{affiliate}") }
  end

  context 'when a BingV7 site' do
    let(:affiliate) { affiliates(:bing_v7_affiliate).name }

    it 'does not issue a redirect' do
      expect(response).to have_http_status(:ok)
    end
  end

  context 'when affiliate do not exists' do
    let(:affiliate) { 'nonexistent' }

    it { is_expected.not_to have_http_status(:internal_server_error) }
  end
end
