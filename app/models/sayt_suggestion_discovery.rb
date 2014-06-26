class SaytSuggestionDiscovery
  extend Resque::Plugins::Priority
  @queue = :primary

  class << self
    def perform(affiliate_name, affiliate_id, day_int, limit)
      day = Date.strptime(day_int.to_s, "%Y%m%d")
      run_rate_factor = Date.current == day ? compute_run_rate_factor : 1.0
      top_n_exists_query = TopNExistsQuery.new(affiliate_name, field: 'raw', min_doc_count: 10, size: limit)
      rtu_top_human_queries = RtuTopQueries.new(top_n_exists_query.body, true, day)
      query_counts = rtu_top_human_queries.top_n
      filtered_query_counts = SaytFilter.filter(query_counts, 0)
      filtered_query_counts.each do |query_count|
        temp_ss = SaytSuggestion.new(phrase: query_count.first)
        temp_ss.squish_whitespace_and_downcase_and_spellcheck
        if (sayt_suggestion = SaytSuggestion.find_or_initialize_by_affiliate_id_and_phrase_and_deleted_at(affiliate_id, temp_ss.phrase, nil))
          sayt_suggestion.popularity = query_count.last * run_rate_factor
          sayt_suggestion.save
        end
      end unless filtered_query_counts.empty?
    end

    def compute_run_rate_factor
      1/ DateTime.current.day_fraction.to_f
    end
  end
end