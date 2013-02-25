YOUTUBE_GDATA_SITE = 'http://gdata.youtube.com'.freeze

$youtube_connection = Faraday.new YOUTUBE_GDATA_SITE do |conn|
  conn.adapter :net_http_persistent
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
