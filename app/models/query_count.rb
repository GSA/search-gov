class QueryCount
  attr_accessor :query, :times, :children

  def initialize(query, times)
    self.query = query
    self.times = times.to_i
    self.children = []
  end
end