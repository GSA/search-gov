class TimeWindowValidator < ActiveModel::EachValidator
  include WatcherDsl
  MAX_DAYS_BACK = 29

  def validate_each(record, attribute, value)
    return if recent_enough?(value)

    record.errors.add(attribute, (options[:message] ||
                                  "exceeds the maximum of #{MAX_DAYS_BACK} days"))

  end

  def recent_enough?(time_window)
    (time_window_as_days_back(time_window) <= MAX_DAYS_BACK) rescue true
  end
end
