module LogstashPrefix
  ES_DATE_UNIT_TO_RUBY = { m: :minutes, h: :hours, d: :days, w: :weeks }

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

  def watcher_indexes_from_window_size(time_window)
    scalar, unit = time_window[0...-1], time_window.last.to_sym
    window_start = Integer(scalar).send(ES_DATE_UNIT_TO_RUBY[unit]).ago.utc
    days_back = yyyymmdd_int(Time.now.utc) - yyyymmdd_int(window_start)
    current_index = "<#{logstash_prefix(true)}{now/d}>"
    days_back.times.map { |i| "<#{logstash_prefix(true)}{now/d-#{i+1}d}>" }.prepend(current_index)
  end

  def yyyymmdd_int(time)
    time.strftime("%Y%m%d").to_i
  end

end
