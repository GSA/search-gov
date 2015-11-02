module QueryCtrCollector
  def low_ctr_queries_from_buckets(buckets, min_ctr, count)
    buckets.select { |bucket| bucket["ctr"]["value"] < min_ctr }.
      map { |bucket| [bucket["key"], bucket["ctr"]["value"]] }.
      sort_by { |arr| arr.last }.first(count)
  end
end
