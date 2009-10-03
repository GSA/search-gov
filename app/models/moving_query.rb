class MovingQuery < ActiveRecord::Base
  validates_presence_of :day
  validates_presence_of :query
  validates_presence_of :window_size
  validates_presence_of :times
  validates_uniqueness_of :query, :scope => [:day, :window_size]
  MIN_NUM_QUERIES_PER_WINDOW = { 1 => 15, 7 => 25, 30 => 45}
  MULTIPLES_OF_STD_DEV_PER_WINDOW = { 1 => 4, 7 => 3, 30 => 2}
  RESULTS_SIZE = 10

  def passes_minimum_thresholds?
    self.times > MIN_NUM_QUERIES_PER_WINDOW[self.window_size] &&
      self.times > (self.mean + (MULTIPLES_OF_STD_DEV_PER_WINDOW[self.window_size] * self.std_dev))
  end

  def self.compute_for(yyyymmdd)
    reversed_backfilled_yearlong_series_hash = {}
    transaction do
      delete_all(["day = ?", yyyymmdd])
      [1, 7, 30].each do |window_size|
        get_window_candidates(window_size, yyyymmdd).each_pair do |query, sum_times|
          reversed_backfilled_yearlong_series = reversed_backfilled_yearlong_series_hash[query]
          if reversed_backfilled_yearlong_series.nil?
            reversed_backfilled_yearlong_series = DailyQueryStat.reversed_backfilled_series_since_2009_for(query, yyyymmdd.to_date)
            reversed_backfilled_yearlong_series_hash[query] = reversed_backfilled_yearlong_series
          end
          window_sums = sum_by_window_except_last(reversed_backfilled_yearlong_series, window_size)
          next if window_sums.length < 2
          next if window_sums[0] <= window_sums[1]
          mean = window_sums.sum / window_sums.length.to_f
          sum_of_squares = window_sums.inject(0) { |acc, i| acc + (i - mean) ** 2 }
          std_dev = Math.sqrt(sum_of_squares / window_sums.length.to_f)
          moving_query = new(:query=> query, :day => yyyymmdd, :window_size => window_size,
                             :times => sum_times, :mean => mean, :std_dev => std_dev)
          moving_query.save if moving_query.passes_minimum_thresholds?
        end
      end
    end
  end

  def self.biggest_movers(end_date, window_size, num_results = RESULTS_SIZE)
    return nil if end_date.nil?
    results= find_all_by_day_and_window_size(end_date.to_date, window_size, :order=>"times DESC")
    return nil if results.empty?
    qcs=[]
    qgcounts = {}
    grouped_queries_hash = GroupedQuery.grouped_queries_hash
    results.each do |res|
      grouped_query = grouped_queries_hash[res.query]
      if (grouped_query && !grouped_query.query_groups.empty?)
        grouped_query.query_groups.each do |query_group|
          qgcounts[query_group.name] = QueryCount.new(query_group.name, 0) if qgcounts[query_group.name].nil?
          qgcounts[query_group.name].times += res.times.to_i
          qgcounts[query_group.name].children << QueryCount.new(res.query, res.times)
        end
      else
        qcs << QueryCount.new(res.query, res.times)
      end
    end
    qcs += qgcounts.values
    qcs.sort_by {|qc| qc.times}.reverse[0, num_results]
  end

  private
  def self.sum_by_window_except_last(ary, window_size)
    return ary if window_size == 1
    windows = ary.in_groups_of(window_size)
    windows = windows[0, (windows.size) - 1] if windows.last.include?nil
    windows.collect {|window| window.sum }
  end

  def self.get_window_candidates(window_size, yyyymmdd)
    start_date = yyyymmdd.to_date - window_size.days + 1.day
    candidates = DailyQueryStat.sum(:times,
                                    :group=>:query,
                                    :conditions=>["day BETWEEN ? AND ?", start_date, yyyymmdd],
                                    :having => "sum_times > #{MIN_NUM_QUERIES_PER_WINDOW[window_size]}")
  end

end
