class NoResultsWatcher < Watcher
  define_hash_columns_accessors column_name_method: :conditions,
                                fields: [:distinct_user_total, :query_blocklist, :time_window]

  validates_numericality_of :distinct_user_total, greater_than_or_equal_to: 1
  validates_presence_of :query_blocklist
  validates_format_of :time_window, with: INTERVAL_REGEXP

end