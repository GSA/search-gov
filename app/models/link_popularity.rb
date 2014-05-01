require 'typhoeus/adapters/faraday'

class LinkPopularity
  @@client = Elasticsearch::Client.new(log: Rails.env == 'development', host: "192.168.100.171")

  def self.popularity_for(url, days_back)
    link_popularity_query = ElasticLinkPopularityQuery.new(url, days_back)
    total = @@client.count(index: "logstash-*", type: 'click', body: link_popularity_query.body)["count"]
    [Math.log10(total), 1.0].max
  end

end