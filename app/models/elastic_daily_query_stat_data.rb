class ElasticDailyQueryStatData
  def initialize(daily_query_stat)
    @daily_query_stat = daily_query_stat
  end

  def to_builder
    Jbuilder.new do |json|
      json.(@daily_query_stat, :id, :affiliate, :day, :query, :times)
    end
  end

end