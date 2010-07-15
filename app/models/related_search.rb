class RelatedSearch
  
  def initialize
  end
  
  # this returns the top 5 related queries for the query passed in.  It uses the SessionRelatedQuery first, then backfills from RelatedQuery
  def related_for(query)
    SessionRelatedQuery.find_by_query(query)
  end
end
