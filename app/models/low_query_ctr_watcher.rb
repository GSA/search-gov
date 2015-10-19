class LowQueryCtrWatcher < Watcher
  define_hash_columns_accessors column_name_method: :conditions,
                                fields: [:search_click_total,
                                         :query_blocklist,
                                         :low_ctr_threshold,
                                         :time_window]

  validates_numericality_of :search_click_total, greater_than_or_equal_to: 50, only_integer: true
  validates_numericality_of :low_ctr_threshold, greater_than: 0.0, less_than: 100.0
  validates_length_of :query_blocklist, maximum: 150, allow_nil: true
  validates :time_window, format: INTERVAL_REGEXP, time_window: true

  def input(json)
    options = { affiliate_name: affiliate.name, time_window: time_window, min_doc_count: search_click_total.to_i, query_blocklist: query_blocklist }
    low_query_ctr_query_body = LowCtrQuery.new(options).body
    json.input do
      json.search do
        json.request do
          json.search_type :count
          json.indices watcher_indexes_from_window_size(time_window)
          json.types %w(search click)
          json.body JSON.parse(low_query_ctr_query_body)
        end
      end
    end
  end

  def condition(json)
    json.condition do
      json.script "ctx.payload.aggregations.agg.buckets.any({ it.ctr.value < #{low_ctr_threshold}})"
    end
  end

  def transform(json)
    json.transform do
      json.script "return ctx.payload.aggregations.agg.buckets.findAll({ it.ctr.value < #{low_ctr_threshold}}).collect({ it.key }).join(', ')"
    end
  end

  def actions(json)
    json.actions do
      # json.email_user do
      #   json.email do
      #     json.account :mandrill
      #     json.to "'#{user.contact_name} <#{user.email}>'"
      #     json.subject "No results detected for certain queries"
      #     json.body "No Results Watcher '#{name}' detected these queries getting no results: {{ctx.payload._value}}"
      #     json.attach_data false
      #   end
      # end
      json.debug_it do
        json.logging do
          json.text "Low Query CTR Watcher '#{name}' detected these queries with low click-thru rates: {{ctx.payload._value}}"
        end
      end
    end
  end

end