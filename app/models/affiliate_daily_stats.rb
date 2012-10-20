module AffiliateDailyStats

  def most_recent_populated_date(affiliate_name)
    maximum(:day, :conditions => ['affiliate = ?', affiliate_name])
  end

  def least_recent_populated_date(affiliate_name)
    minimum(:day, :conditions => ['affiliate = ?', affiliate_name])
  end

  def available_dates_range(affiliate_name)
    if (lrpd = least_recent_populated_date(affiliate_name))
      lrpd..most_recent_populated_date(affiliate_name)
    else
      Date.yesterday..Date.yesterday
    end
  end
end
