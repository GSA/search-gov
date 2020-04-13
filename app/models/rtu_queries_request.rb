# frozen_string_literal: true

class RtuQueriesRequest
  MAX_RESULTS = 1000
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include LogstashPrefix
  include RtuAnalyticsRequestable

  attr_reader :start_date, :end_date, :available_dates, :filter_bots
  attribute :site, Affiliate
  attribute :start_date, String
  attribute :end_date, String
  attribute :filter_bots, Boolean

  attr_reader :query
  attribute :query, String

  def top_queries
    @top_stats
  end

  private

  def compute_top_stats
    search_click_buckets = top_n(search_query.body)
    stats_from_buckets(search_click_buckets) if search_click_buckets.present?
  end

  def stats_from_buckets(search_click_buckets)
    search_click_buckets.map { |bucket| extract_query_click_count(bucket) }.sort_by { |query_click_count| -query_click_count.queries }
  end

  def extract_query_click_count(bucket)
    term = bucket['key']
    types_buckets = bucket['type']['buckets']
    search_click_bucket = Hash[types_buckets.collect { |hash| [hash["key"], hash["doc_count"]] }]
    qcount = search_click_bucket['search'] || 1
    ccount = search_click_bucket['click'] || 0
    ctr = 100 * ccount / qcount
    QueryClickCount.new(term, qcount, ccount, ctr, is_routed_query?(term))
  end

  def top_n(query_body)
    ES::ELK.client_reader.search(
      index: "#{logstash_prefix(filter_bots)}*",
      body: query_body,
      size: 0
    )['aggregations']['agg']['buckets']
  rescue StandardError
    nil
  end

  def is_routed_query?(term)
    routed_query_keywords.include? term
  end

  def routed_query_keywords
    @routed_query_keywords ||= Set.new(site.routed_query_keywords.collect(&:keyword))
  end

  def search_query
    TopQueryMatchQuery.new(site.name,
                           query,
                           start_date,
                           end_date,
                           field: 'params.query.raw',
                           size: MAX_RESULTS)
  end
end
