YOUTUBE_GDATA_SITE = 'http://gdata.youtube.com'.freeze

$youtube_connection = Faraday.new YOUTUBE_GDATA_SITE do |conn|
  conn.adapter :net_http_persistent
end

module YoutubeConnection
  class RequestError < RuntimeError
  end

  class QuotaError < RuntimeError
  end

  def self.get(url)
    response = $youtube_connection.get(url.sub(%r[^https?://gdata\.youtube\.com]i, ''))
    case
      when response.status == 200
        response.body
      when response.status == 403, response.body =~ /yt:quota/i
        raise QuotaError.new "url: #{url} HTTP status: #{response.status} body: #{response.body}"
      else
        raise RequestError.new "url: #{url} HTTP status: #{response.status} body: #{response.body}"
    end
  end
end
