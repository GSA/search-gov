# frozen_string_literal: true

class NoResultsWatcher < Watcher
  WATCHER_DEFAULTS = { distinct_user_total: 50 }
  define_hash_columns_accessors column_name_method: :conditions,
                                fields: [:distinct_user_total]

  validates_numericality_of :distinct_user_total, greater_than_or_equal_to: 1, only_integer: true

  def humanized_alert_threshold
    "#{number_with_delimiter distinct_user_total} Queries"
  end

  def input(json)
    options = { affiliate_name: affiliate.name,
                time_window: time_window,
                min_doc_count: distinct_user_total.to_i,
                query_blocklist: query_blocklist,
                size: 10 }
    no_results_query_body = WatcherNoResultsQuery.new(options).body
    input_search_request(json,
                         indices: watcher_indexes_from_window_size(time_window),
                         body: JSON.parse(no_results_query_body).merge(size: 0))
  end

  def condition_script
    'ctx.payload.aggregations.agg.buckets.size() > 0'
  end

  def transform_script
    'ctx.payload.aggregations.agg.buckets.collect(it -> it.key)'
  end

  def label
    'No Results'
  end
end
