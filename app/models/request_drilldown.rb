# frozen_string_literal: true

class RequestDrilldown
  include LogstashPrefix
  MAX_RESULTS = 10_000

  def initialize(filtered_totals, drilldown_query_body)
    @filtered_totals = filtered_totals
    @drilldown_query_body = drilldown_query_body
  end

  def docs
    response = Es::ELK.client_reader.search(**query_opts)
    response['hits']['hits']&.map { |hit| hit['_source'] }
  rescue StandardError => error
    Rails.logger.error("Error extracting drilldown hits: #{error}")
    []
  end

  private

  def query_opts
    {
      index: "#{logstash_prefix(@filtered_totals)}*",
      body: @drilldown_query_body,
      size: MAX_RESULTS,
      sort: '@timestamp:asc'
    }
  end
end
