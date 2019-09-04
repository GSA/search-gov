class TimeWindowValidator < ActiveModel::EachValidator
  include WatcherDSL
  MAX_DAYS_BACK = 29

  def validate_each(record, attribute, value)
    unless recent_enough?(value)
      record.errors.add(attribute, (options[:message] ||
                                    "exceeds the maximum of #{MAX_DAYS_BACK} days"))
    end
  end

  def recent_enough?(time_window)
    (time_window_as_days_back(time_window) <= MAX_DAYS_BACK) rescue true
  end
end
