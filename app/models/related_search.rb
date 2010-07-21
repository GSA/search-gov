class RelatedSearch
  DEFAULT_RESULT_SIZE = 5
  
  # this returns the top 5 related queries for the query passed in.  It uses the SessionRelatedQuery first, then backfills from RelatedQuery
  def self.related_to(query)
    related_queries = RelatedQuery.find_all_by_query(query, :order => 'score desc')
  end
end
