# frozen_string_literal: true

module WatcherDSL
  ES_DATE_UNIT_TO_RUBY = { m: :minutes, h: :hours, d: :days, w: :weeks }.freeze

  def query_blocklist_filter(json, query_blocklist)
    return if query_blocklist.blank?

    json.child! do
      json.terms do
        json.set! 'params.query.raw', query_blocklist.downcase.split(',').map(&:strip)
      end
    end
  end

  def start_end_from_time_window(time_window)
    ["{{ctx.trigger.scheduled_time}}||-#{time_window}",
     '{{ctx.trigger.scheduled_time}}']
  end

  def watcher_indexes_from_window_size(time_window)
    days_back = time_window_as_days_back(time_window)
    current_index = "<#{logstash_prefix(true)}{now/d{YYYY.MM.dd}}>"
    days_back.times.map do |num|
      "<#{logstash_prefix(true)}{now/d-#{num + 1}d{YYYY.MM.dd}}>"
    end.prepend(current_index)
  end

  def time_window_as_days_back(time_window)
    window_start = es_time_offset_to_time(time_window)
    ((Time.now.utc - window_start) / 86_400).round + 1
  end

  def es_time_offset_to_time(time_window)
    scalar = time_window[0...-1]
    unit = time_window.last.to_sym
    Integer(scalar).send(ES_DATE_UNIT_TO_RUBY[unit]).ago.utc
  end
end
