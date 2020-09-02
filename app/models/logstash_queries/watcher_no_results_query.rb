# frozen_string_literal: true

class WatcherNoResultsQuery < DateRangeTopNMissingQuery
  include WatcherDSL

  def initialize(options)
    start_date, end_date = start_end_from_time_window(options[:time_window])
    @query_blocklist = options[:query_blocklist]
    super(options[:affiliate_name],
          'search',
          start_date,
          end_date,
          options.slice(:min_doc_count, :size).merge(field: 'params.query.raw'))
  end

  def additional_must_nots(json)
    super(json)
    query_blocklist_filter json, @query_blocklist
  end
end
