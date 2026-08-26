# frozen_string_literal: true

class RtuPopularRawHumanArray
  MAX_RESULTS = 50_000
  RESULTS_SIZE = 10
  INSUFFICIENT_DATA = 'Not enough historic data to compute most popular'

  def initialize(site_name, start_date, end_date, num_results = RESULTS_SIZE)
    @site_name = site_name
    @start_date = start_date
    @end_date = end_date
    @num_results = num_results
  end

  def most_popular
    return INSUFFICIENT_DATA if @end_date.nil? or @start_date.nil?

    date_range_top_n_query = DateRangeTopNQuery.new(*query_args)
    cnt_arr = query_class.new(date_range_top_n_query.body).top_n
    return INSUFFICIENT_DATA if cnt_arr.empty?

    cnt_arr.sort_by { |a| -a.last }.first(@num_results)
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
