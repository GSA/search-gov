module WatcherDSL
  ES_DATE_UNIT_TO_RUBY = { m: :minutes, h: :hours, d: :days, w: :weeks }

  def query_blocklist_filter(json, query_blocklist)
    json.child! do
      json.terms do
        json.raw query_blocklist.split(',').map { |term| term.strip.downcase }
      end
    end if query_blocklist.present?
  end

  def start_end_from_time_window(time_window)
    ["{{ctx.trigger.scheduled_time}}||-#{time_window}", "{{ctx.trigger.scheduled_time}}"]
  end

  def watcher_indexes_from_window_size(time_window)
    days_back = time_window_as_days_back(time_window)
    current_index = "<#{logstash_prefix(true)}{now/d}>"
    days_back.times.map { |i| "<#{logstash_prefix(true)}{now/d-#{i+1}d}>" }.prepend(current_index)
  end

  def time_window_as_days_back(time_window)
    window_start = es_time_offset_to_time(time_window)
    ((Time.now.utc - window_start)/86400).round + 1
  end

  def es_time_offset_to_time(time_window)
    scalar, unit = time_window[0...-1], time_window.last.to_sym
    Integer(scalar).send(ES_DATE_UNIT_TO_RUBY[unit]).ago.utc
  end

end
