# frozen_string_literal: true

class LinkPopularity
  extend LogstashPrefix

  def self.popularity_for(url, days_back)
    link_popularity_query = ElasticLinkPopularityQuery.new(url, days_back)
    total = ES::ELK.client_reader.count(
      index: indexes_to_date(days_back, true),
      body: link_popularity_query.body
    )['count']
    [Math.log10(total), 1.0].max
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    1.0
  end
end
