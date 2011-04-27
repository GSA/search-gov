class MovingQuery < ActiveRecord::Base
  validates_presence_of :day
  validates_presence_of :query
  validates_presence_of :times
  validates_uniqueness_of :query, :scope => :day
  MIN_NUM_QUERIES = 15
  MIN_ACCELERATION_PERIODS_REQUIRED = 7
  MULTIPLES_OF_STD_DEV = 4
  RESULTS_SIZE = 10
  NO_QUERIES_MATCHED = "No queries matched"
  INSUFFICIENT_DATA = "Not enough historic data to compute accelerations"

  def passes_minimum_thresholds?
    self.times > MIN_NUM_QUERIES && self.times > (self.mean + (MULTIPLES_OF_STD_DEV * self.std_dev))
  end

  def self.compute_for(yyyymmdd)
    reversed_backfilled_yearlong_series_hash = {}
    delete_all(["day = ?", yyyymmdd])
    get_moving_query_candidates(yyyymmdd).each_pair do |query, sum_times|
      reversed_backfilled_yearlong_series = reversed_backfilled_yearlong_series_hash[query]
      if reversed_backfilled_yearlong_series.nil?
        reversed_backfilled_yearlong_series = DailyQueryStat.reversed_backfilled_series_since_2009_for(query, yyyymmdd.to_date)
        reversed_backfilled_yearlong_series_hash[query] = reversed_backfilled_yearlong_series
      end
      next if reversed_backfilled_yearlong_series.length < 2 or reversed_backfilled_yearlong_series[0] <= reversed_backfilled_yearlong_series[1]
      mean = reversed_backfilled_yearlong_series.sum / reversed_backfilled_yearlong_series.length.to_f
      sum_of_squares = reversed_backfilled_yearlong_series.inject(0) { |acc, i| acc + (i - mean) ** 2 }
      std_dev = Math.sqrt(sum_of_squares / reversed_backfilled_yearlong_series.length.to_f)
      moving_query = new(:query=> query, :day => yyyymmdd, :times => sum_times, :mean => mean, :std_dev => std_dev)
      moving_query.save if moving_query.passes_minimum_thresholds?
    end
  end

  def self.biggest_movers(end_date, num_results = RESULTS_SIZE)
    return NO_QUERIES_MATCHED if end_date.nil?
    results= find_all_by_day(end_date.to_date, :order=>"times DESC", :limit => num_results)
    return NO_QUERIES_MATCHED if results.empty?
    return INSUFFICIENT_DATA if insufficient_data?(end_date)
    results.collect { |res| QueryCount.new(res.query, res.times) }
  end

  private

  def self.get_moving_query_candidates(yyyymmdd)
    DailyQueryStat.sum(:times, :group=>:query, :conditions=>["day = ?", yyyymmdd], :having => "sum_times > #{MIN_NUM_QUERIES}")
  end

  def self.insufficient_data?(day)
    available_periods = day - minimum(:day)
    available_periods < MIN_ACCELERATION_PERIODS_REQUIRED
  end

end
