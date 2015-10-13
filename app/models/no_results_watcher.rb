class NoResultsWatcher < Watcher
  define_hash_columns_accessors column_name_method: :conditions,
                                fields: [:distinct_user_total,
                                         :query_blocklist,
                                         :time_window]

  validates_numericality_of :distinct_user_total, greater_than_or_equal_to: 1
  validates_length_of :query_blocklist, maximum: 150, allow_nil: true
  validates_format_of :time_window, with: INTERVAL_REGEXP

  def input(json)
    no_results_query = WatcherTopNMissingQuery.new(self, field: 'raw', min_doc_count: distinct_user_total)
    json.input do
      json.search do
        json.request do
          json.search_type :count
          json.indices watcher_indexes_from_window_size(time_window)
          json.body JSON.parse(no_results_query.body)
        end
      end
    end
  end

  def condition(json)
    json.condition do
      json.compare do
        json.set! "ctx.payload.aggregations.agg.buckets.0.doc_count" do
          json.gt 0
        end
      end
    end
  end

  def transform(json)
    json.transform do
      json.script "return ctx.payload.aggregations.agg.buckets.collect({ it.key }).join(', ')"
    end
  end

  def actions(json)
    json.actions do
      json.email_user do
        json.throttle_period throttle_period
        json.email do
          json.to "'#{user.contact_name} <#{user.email}>'"
          json.subject "No results detected for certain queries"
          json.body "No Results Watcher {{ctx.watch_id}} detected these queries getting no results: {{ctx.payload}}"
          json.attach_data true
        end
      end
      json.debug_it do
        json.logging do
          json.text "No Results Watcher {{ctx.watch_id}} detected these queries getting no results: {{ctx.payload}}"
        end
      end
    end
  end
end