# frozen_string_literal: true

class LowQueryCtrWatcher < Watcher
  WATCHER_DEFAULTS = { search_click_total: 100, low_ctr_threshold: 15 }.freeze

  # SRCH-3206 update: In the future, we may wish to transition to using a json db data type for the conditions column,
  # but deferring for now.
  store_accessor :conditions, :search_click_total
  store_accessor :conditions, :low_ctr_threshold

  validates :search_click_total, numericality: { greater_than_or_equal_to: 20, only_integer: true }
  validates :low_ctr_threshold, numericality: { greater_than: 0.0, less_than: 100.0 }

  def humanized_alert_threshold
    "#{low_ctr_threshold}% CTR on #{number_with_delimiter(search_click_total)} Queries & Clicks"
  end

  def label
    'Low Query Click-Through Rate (CTR)'
  end

  private

  def input(json)
    options = { affiliate_name: affiliate.name,
                time_window: time_window,
                min_doc_count: search_click_total.to_i,
                query_blocklist: query_blocklist }
    low_query_ctr_query_body = WatcherLowCtrQuery.new(options).body
    input_search_request(json,
                         indices: watcher_indexes_from_window_size(time_window),
                         body: JSON.parse(low_query_ctr_query_body).merge(size: 0))
  end

  def condition_script
    "ctx.payload.aggregations.agg.buckets.any(it -> it.ctr.value < #{low_ctr_threshold})"
  end

  def transform_script
    "ctx.payload.aggregations.agg.buckets.findAll(it -> it.ctr.value < #{low_ctr_threshold}).collect(it -> it.key).join('\",\"')"
  end
end
