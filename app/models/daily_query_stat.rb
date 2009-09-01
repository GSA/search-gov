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

  def self.biggest_mover_popularity_over_window(window_size)
    yesterday = 1.days.ago.to_date
    start_date = window_size.days.ago.to_date
    results = DailyQueryStat.find_by_sql("SELECT * FROM query_accelerations qa, (SELECT sum(times) AS sum_times, query AS query FROM daily_query_stats WHERE (day between '#{start_date}' AND '#{yesterday}') GROUP BY query ) as dqs WHERE (qa.day = '#{yesterday}' AND qa.window_size = #{window_size} and qa.query=dqs.query) ORDER BY score desc LIMIT #{RESULTS_SIZE}")
    results.empty? ? nil : results
  end
end
