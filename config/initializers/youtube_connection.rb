YOUTUBE_GDATA_SITE = 'http://gdata.youtube.com'.freeze
YOUTUBE_GDATA_CACHE_DURATION_IN_SECONDS = (60 * 60 * 2).freeze

$youtube_connection = Faraday.new YOUTUBE_GDATA_SITE do |conn|
  cache_dir = File.join(Rails.root, 'tmp', 'cache')
  conn.adapter :net_http_persistent
  conn.response :caching do
    ActiveSupport::Cache::FileStore.new cache_dir, namespace: 'yt_api', expires_in: YOUTUBE_GDATA_CACHE_DURATION_IN_SECONDS
  end
end

module YoutubeConnection
  def self.get(url)
    response = $youtube_connection.get(url.sub(%r[^https?://gdata\.youtube\.com]i, ''))
    if response.status == 200
      response.body
    else
      raise "HTTP status:#{response.status} url:#{url} body: #{response.body}"
    end
  end
end
