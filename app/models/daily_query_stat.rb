class DailyQueryStat < ActiveRecord::Base
  validates_presence_of :day
  validates_presence_of :query
  validates_presence_of :times
  validates_uniqueness_of :query, :scope => :day
  RESULTS_SIZE = 10

  def self.popular_terms_over_days(days_back)
    yesterday = 1.days.ago.to_date
    start_date = days_back.days.ago.to_date
    results = DailyQueryStat.sum(:times,
                       :group => :query,
                       :conditions => ['day between ? AND ?', start_date, yesterday],
                       :order => "sum_times desc",
                       :limit => RESULTS_SIZE)
    results.empty? ? nil : results
  end
end
