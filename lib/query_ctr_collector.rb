module QueryCtrCollector
  def low_ctr_queries_from_hashes(clicks_hash, searches_hash, min_ctr, count)
    searches_hash.inject([]) do |result, (term, qcount)|
      ccount = clicks_hash[term] || 0
      ctr = 100 * ccount / qcount
      result << [term, ctr] if ctr < min_ctr
      result
    end.sort_by { |arr| arr.last }.first(count)
  end
end
