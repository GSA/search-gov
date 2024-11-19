# frozen_string_literal: true

describe 'Bing search' do
  describe 'web search' do
    let(:web_subscription_id) { ENV.fetch('BING_WEB_SUBSCRIPTION_ID') }
    let(:web_search_host) { 'api.bing.microsoft.com' }
    let(:web_search_path) { '/v7.0/search' }

    before do
      stub_request(:get, web_search_host)
      BingV7WebSearch.new(query: 'building').execute_query
    end

    it 'uses the web search key and end point' do
      skip 'Bing is failing and Jim has approved skipping of Bing tests.'

      expect(WebMock).to have_requested(:get, /#{web_search_host}#{web_search_path}/).
        with(headers: { 'Ocp-Apim-Subscription-Key' => web_subscription_id })
    end
  end
end
