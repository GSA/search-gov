# frozen_string_literal: true

class RtuPopularRawHumanArray
  MAX_RESULTS = 1000000
  RESULTS_SIZE = 10
  INSUFFICIENT_DATA = "Not enough historic data to compute most popular"

  def initialize(site_name, start_date, end_date, num_results = RESULTS_SIZE)
    @site_name, @start_date, @end_date, @num_results = site_name, start_date, end_date, num_results
  end

  def most_popular
    return INSUFFICIENT_DATA if @end_date.nil? or @start_date.nil?
    date_range_top_n_query = DateRangeTopNQuery.new(*query_args)
    rtu_most_popular = query_class.new(date_range_top_n_query.body, false)
    raw_cnt_arr = rtu_most_popular.top_n
    rtu_human_most_popular = query_class.new(date_range_top_n_query.body, true)
    human_cnt_hash = Hash[rtu_human_most_popular.top_n]
    return INSUFFICIENT_DATA if human_cnt_hash.empty?
    raw_human_arr = raw_cnt_arr.map do |popular_term, raw_count|
      human_count = human_cnt_hash[popular_term] || 0
      [popular_term, raw_count, human_count]
    end
    raw_human_arr.sort_by { |a| -a.last }.first(@num_results)

  end

  private

  def query_args
    [
      @site_name,
      type,
      @start_date,
      @end_date,
      { field: aggs_field, size: MAX_RESULTS }
    ]
  end
end
