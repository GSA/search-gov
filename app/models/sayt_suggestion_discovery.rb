class SaytSuggestionDiscovery
  extend Resque::Plugins::Priority
  extend ResqueJobStats
  @queue = :primary

  class << self
    MIN_DOC_COUNT = 5

    def perform(affiliate_name, affiliate_id, day_int, limit)
      day = Date.strptime(day_int.to_s, "%Y%m%d")
      run_rate_factor = Date.current == day ? compute_run_rate_factor : 1.0
      top_n_exists_query = TopNExistsQuery.new(affiliate_name,
                                               'search',
                                               field: 'params.query.raw',
                                               min_doc_count: MIN_DOC_COUNT,
                                               size: limit)
      rtu_top_human_queries = RtuTopQueries.new(top_n_exists_query.body, true, day)
      query_counts = rtu_top_human_queries.top_n
      filtered_query_counts = SaytFilter.filter(query_counts, 0)
      collect_filtered_query_counts(affiliate_id, filtered_query_counts, run_rate_factor) unless filtered_query_counts.empty?
    end

    def collect_filtered_query_counts(affiliate_id, filtered_query_counts, run_rate_factor)
      filtered_query_counts.each do |query_count|
        process_query_count(affiliate_id, query_count, run_rate_factor)
      end
    end

    def process_query_count(affiliate_id, query_count, run_rate_factor)
      temp_ss = SaytSuggestion.new(phrase: query_count.first)
      temp_ss.squish_whitespace_and_downcase_and_spellcheck
      sayt_suggestion = SaytSuggestion.find_or_initialize_by(affiliate_id: affiliate_id, phrase: temp_ss.phrase, deleted_at: nil)
      if sayt_suggestion.present?
        sayt_suggestion.popularity = query_count.last * run_rate_factor
        sayt_suggestion.save
      end
    end

    def compute_run_rate_factor
      1/ DateTime.current.day_fraction.to_f
    end
  end
end
