class QueryCtrStat
  attr_reader :query, :historical, :recent

  def initialize(query, historical, recent)
    @query = query
    @historical, @recent = historical, recent
  end

end