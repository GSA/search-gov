class NoResultsWatcher < Watcher
  define_hash_columns_accessors column_name_method: :conditions,
                                fields: [:distinct_user_total]

  validates_numericality_of :distinct_user_total, greater_than_or_equal_to: 1, only_integer: true

  def input(json)
    no_results_query_body = WatcherTopNMissingQuery.new(self, field: 'raw', min_doc_count: distinct_user_total.to_i, size: 10).body
    json.input do
      json.search do
        json.request do
          json.search_type :count
          json.indices watcher_indexes_from_window_size(time_window)
          json.types %w(search)
          json.body JSON.parse(no_results_query_body)
        end
      end
    end
  end

  def condition(json)
    json.condition do
      json.script do
        json.inline "ctx.payload.aggregations && ctx.payload.aggregations.agg.buckets.size() > 0"
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
        json.email do
          json.account :mandrill
          json.to "'#{user.contact_name} <#{user.email}>'"
          json.subject "No results detected for certain queries"
          json.body "No Results Watcher '#{name}' detected these queries getting no results: {{ctx.payload._value}}"
          json.attach_data false
        end
      end
    end
  end

end