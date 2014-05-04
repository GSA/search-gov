module Duration
  def self.seconds_to_hoursminssecs(seconds)
    return if seconds.zero?

    duration_hours = seconds / 1.hour
    hours_with_delimiter = duration_hours.zero? ? '' : "#{duration_hours}:"

    seconds -= duration_hours.hours unless duration_hours.zero?

    duration_minutes = seconds / 1.minute
    minutes_with_delimiter = duration_hours.zero? ? "#{duration_minutes}:" : sprintf('%02d:', duration_minutes)

    seconds -= duration_minutes.minutes unless duration_minutes.zero?
    duration_seconds = sprintf '%02d', seconds

    "#{hours_with_delimiter}#{minutes_with_delimiter}#{duration_seconds}"
  end
end
