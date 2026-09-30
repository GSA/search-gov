module LogstashPrefix

  private
  def logstash_prefix
    "human-logstash-"
  end

  def indexes_to_date(historical_days_back)
    end_date = Date.current
    start_date = end_date - historical_days_back.days
    range = start_date..end_date
    range.collect { |date| "#{logstash_prefix}#{date.strftime("%Y.%m.%d")}" }
  end

  def monthly_index_wildcard_spanning_date(day)
    "#{logstash_prefix}#{day.strftime("%Y.%m.")}*"
  end

end
