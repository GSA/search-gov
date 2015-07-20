class QueryClickCount
  attr_accessor :query, :queries, :clicks, :ctr, :is_routed_query

  def initialize(query, queries, clicks, ctr, is_routed_query)
    self.query = query
    self.queries = queries.to_i
    self.clicks = clicks.to_i
    self.ctr = ctr.to_f
    self.is_routed_query = is_routed_query
  end
end