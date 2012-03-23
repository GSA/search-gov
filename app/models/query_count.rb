class QueryCount
  attr_accessor :query, :times

  def initialize(query, times)
    self.query = query
    self.times = times.to_i
  end
end