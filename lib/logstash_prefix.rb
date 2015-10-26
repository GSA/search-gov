module LogstashPrefix

  private
  def logstash_prefix(filter_bots)
    filter_bots ? "human-logstash-" : "logstash-"
  end

  def indexes_to_date(historical_days_back, filter_bots)
    end_date = Date.current
    start_date = end_date - historical_days_back.days
    range = start_date..end_date
    range.collect { |date| "#{logstash_prefix(filter_bots)}#{date.strftime("%Y.%m.%d")}" }
  end

  def monthly_index_wildcard_spanning_date(day, filter_bots)
    "#{logstash_prefix(filter_bots)}#{day.strftime("%Y.%m.")}*"
  end

end
