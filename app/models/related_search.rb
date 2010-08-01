class RelatedSearch
  DEFAULT_RESULT_SIZE = 5
  
  # this returns the top 5 related queries for the query passed in.  It uses the SessionRelatedQuery first, then backfills from RelatedQuery
  def self.related_to(query)
    related_queries = RelatedQuery.find_all_by_query(query, :order => 'score desc').collect{|related_query| related_query.related_query}
    if related_queries.size < 5
      related_processed_queries = ProcessedQuery.related_to(query, :per_page => 5 - related_queries.size).results.collect{|processed_query| processed_query.query}
      related_queries.concat(related_processed_queries)
    end
    related_queries
  end
end
