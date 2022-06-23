# frozen_string_literal: true

class RtuTopN
  include LogstashPrefix

  def initialize(query_body, filter_bots, day)
    @query_body = query_body
    @filter_bots = filter_bots
    @day = day.present? ? day.strftime('%Y.%m.%d') : '*'
  end

  def top_n
    term_buckets.collect { |hash| [hash['key'], hash['doc_count']] }
  end

  private

  def query_opts
    {
      index: "#{logstash_prefix(@filter_bots)}#{@day}",
      body: @query_body,
      size: 10_000
    }
  end

  def response
    Es::ELK.client_reader.search(query_opts)
  rescue StandardError => error
    Rails.logger.error("Error querying top_n data: #{error}")
    {}
  end

  def term_buckets
    response.dig('aggregations', 'agg', 'buckets') || []
  end
end
