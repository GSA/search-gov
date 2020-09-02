# frozen_string_literal: true

module Ctrs

  private
  def ctrs(query_body, historical_days_back = 0)
    params = {
      index: indexes_to_date(historical_days_back, true),
      body: query_body,
      size: 0,
      ignore_unavailable: true
    }
    ES::ELK.client_reader.search(params)["aggregations"]["agg"]["buckets"] rescue nil
  end

  def convert_to_hash(buckets)
    Hash[buckets.collect { |hash| [hash["key"], extract_impression_click_stat(hash['type']['buckets'])] }] if buckets
  end

  def extract_impression_click_stat(types_buckets)
    search_click_bucket = Hash[types_buckets.collect { |hash| [hash["key"], hash["doc_count"]] }]
    qcount = search_click_bucket['search'] || 0
    ccount = search_click_bucket['click'] || 0
    ImpressionClickStat.new(qcount, ccount)
  end

end
