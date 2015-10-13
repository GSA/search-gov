class NoResultsWatcher < Watcher
  define_hash_columns_accessors column_name_method: :conditions,
                                fields: [:distinct_user_total,
                                         :query_blocklist,
                                         :time_window]

  validates_numericality_of :distinct_user_total, greater_than_or_equal_to: 1
  validates_length_of :query_blocklist, maximum: 150, allow_nil: true
  validates_format_of :time_window, with: INTERVAL_REGEXP

  def input(json)
    no_results_query = TopNMissingQuery.new(affiliate.name, field: 'raw', min_doc_count: distinct_user_total)
    json.input do
      json.search do
        json.request do
          json.indices watcher_indexes_from_window_size(time_window)
        end
        json.body JSON.parse(no_results_query.body)
      end
    end
  end

  def condition(json)
    json
  end

  def actions(json)
    json.email_user do
      json.throttle_period throttle_period
      json.email do
        json.to "'#{user.contact_name} <#{user.email}>'"
        json.subject "No results detected for certain queries"
        json.body "{{ctx.watch_id}} executed with {{ctx.payload.hits.total}} hits. {somehow put in the no_result_query_terms}"
        json.attach_data true
      end
    end
  end
end