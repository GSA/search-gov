# frozen_string_literal: true

class ElasticTextFilterByPublishedAtQuery < ElasticTextFilteredQuery
  def initialize(options)
    super

    @since_ts = options[:since]
    @until_ts = options[:until]
  end

  def published_at_filter(json)
    json.range do
      json.published_at do
        json.gt @since_ts if @since_ts
        json.lt @until_ts if @until_ts
      end
    end
  end
end
