class LinkPopularity

  def self.popularity_for(url, days_back)
    link_popularity_query = ElasticLinkPopularityQuery.new(url, days_back)
    total = ES.client_reader.count(index: "logstash-*", type: 'click', body: link_popularity_query.body)["count"]
    [Math.log10(total), 1.0].max
  end

end