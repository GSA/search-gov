class QueryCount
  attr_accessor :query, :times, :is_grouped

  def initialize(query, times, is_grouped = false)
    self.query = query
    self.times = times.to_i
    self.is_grouped = is_grouped
  end
  alias_method :is_grouped?, :is_grouped
end