require 'spec_helper'

describe SearchConsumer::API do
  fixtures :affiliates, :rss_feed_urls, :rss_feeds, :navigations, :news_items, :youtube_profiles

  let(:affiliate) { affiliates(:basic_affiliate) }

  before do
    NewsItem.all.each { |news_item| news_item.save! }
    ElasticNewsItem.commit
  end

  let(:rss_feed) { rss_feeds(:white_house_blog) }

  context 'GET /api/c/affiliate/:name/rss/:channel_id' do
    it 'returns a list of results for an RSS channel with no results' do
      get "/api/c/search/rss/#{rss_feed.id}?affiliate=nps.gov&sc_access_key=#{SC_ACCESS_KEY}&query=df"
      expect(response.status).to eq(200)
      expect(response.body).to eq({
        next_offset: nil,
        count: 0,
        results: []
        }.to_json)
    end

    it 'returns a list of results for an RSS channel with results' do
      get "/api/c/search/rss/#{rss_feed.id}?affiliate=nps.gov&sc_access_key=#{SC_ACCESS_KEY}&query=element"
      expect(response.status).to eq(200)
      expect(response.body).to include_json(
        next_offset: nil,
        count: 1
      )
    end

    it 'returns a an error if a query param is not present' do
      get "/api/c/search/rss/#{rss_feed.id}?affiliate=nps.gov&sc_access_key=#{SC_ACCESS_KEY}"
      expect(response.status).to eq(400)
      expect(response.body).to eq({
        error: 'query is missing'
      }.to_json)
    end

    it 'returns a 401 unauthroized if there is no valid sc_access_key param' do
      get '/api/c/search/rss/1?site_handle=nps.gov&sc_access_key=invalidKey&query=test'
      expect(response.status).to eq(401)
    end
  end


end
