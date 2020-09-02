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

  # Results representing a given percentage of all results by doc_count
  def top_n_to_percentage(percent)
    top = top_n
    total = top.map(&:last).sum
    cumulative_count = 0.0
    top_to_percentage = []

    while (cumulative_count / total) * 100 < percent
      result = top.shift
      top_to_percentage << result
      cumulative_count += result[1]
    end
    top_to_percentage
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
    ES::ELK.client_reader.search(query_opts)
  rescue StandardError => error
    Rails.logger.error("Error querying top_n data: #{error}")
    {}
  end

  def term_buckets
    response.dig('aggregations', 'agg', 'buckets') || []
  end
end
