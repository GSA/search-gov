class WatcherLowCtrQuery < LowCtrQuery
  include WatcherDSL

  def initialize(options)
    end_date, start_date = start_end_from_time_window(options[:time_window])
    @query_blocklist = options[:query_blocklist]
    super(options[:affiliate_name], start_date, end_date, options.slice(:min_doc_count))
  end

  def additional_must_nots(json)
    super(json)
    query_blocklist_filter @query_blocklist
  end


end