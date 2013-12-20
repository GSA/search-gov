class QueryClickCount
  attr_accessor :query, :queries, :clicks, :ctr

  def initialize(query, queries, clicks, ctr)
    self.query = query
    self.queries = queries.to_i
    self.clicks = clicks.to_i
    self.ctr = ctr.to_f
  end
end