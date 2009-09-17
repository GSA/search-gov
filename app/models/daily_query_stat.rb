class DailyQueryStat < ActiveRecord::Base
  validates_presence_of :day
  validates_presence_of :query
  validates_presence_of :times
  validates_uniqueness_of :query, :scope => :day
  RESULTS_SIZE = 10

  def self.most_popular_terms(end_date, days_back, num_results = RESULTS_SIZE)
    return nil if end_date.nil?
    start_date = end_date - days_back.days + 1.day
    results = DailyQueryStat.sum(:times,
                                 :group => :query,
                                 :conditions => ['day between ? AND ?', start_date, end_date],
                                 :order => "sum_times desc",
                                 :limit => num_results)
    results.empty? ? nil : results
  end

  def self.biggest_movers(end_date, window_size, num_results = RESULTS_SIZE)
    return nil if end_date.nil?
    start_date = end_date - window_size.days + 1.day
    results = DailyQueryStat.find_by_sql("SELECT * FROM query_accelerations qa, (SELECT sum(times) AS sum_times, query AS query FROM daily_query_stats WHERE (day between '#{start_date}' AND '#{end_date}') GROUP BY query  ) as dqs WHERE (qa.day = '#{end_date}' AND qa.window_size = #{window_size} and qa.query=dqs.query) ORDER BY score DESC LIMIT #{num_results}").sort_by {|dqs| dqs[:sum_times].to_i}.reverse
    results.empty? ? nil : results
  end

  def self.most_recent_populated_date
    maximum(:day)
  end
end
