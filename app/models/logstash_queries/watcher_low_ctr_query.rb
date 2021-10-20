class WatcherLowCtrQuery < LowCtrQuery
  include WatcherDsl

  def initialize(options)
    start_date, end_date = start_end_from_time_window(options[:time_window])
    @query_blocklist = options[:query_blocklist]
    super(options[:affiliate_name], start_date, end_date, options.slice(:min_doc_count))
  end

  def additional_must_nots(json)
    super(json)
    query_blocklist_filter json, @query_blocklist
  end
end
