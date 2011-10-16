class Analytics::GroupsTrendsController < Analytics::AnalyticsController
  MAX_NUMBER_OF_BIG_MOVERS_TO_SHOW = 21

  def index
    @page_title = 'Groups & Trends'
    @day_being_shown = request["day"].blank? ? DailyQueryStat.most_recent_populated_date : request["day"].to_date
    @available_dates = DailyQueryStat.available_dates_range
    @num_results_dqgs = (request["num_results_dqgs"] || "10").to_i
    @most_recent_day_biggest_movers = MovingQuery.biggest_movers(@day_being_shown, MAX_NUMBER_OF_BIG_MOVERS_TO_SHOW)
    @most_recent_day_popular_query_groups = DailyPopularQueryGroup.get_by_day_and_time_frame(@day_being_shown, 1, @num_results_dqgs)
    @trailing_week_popular_query_groups = DailyPopularQueryGroup.get_by_day_and_time_frame(@day_being_shown, 7, @num_results_dqgs)
    @trailing_month_popular_query_groups = DailyPopularQueryGroup.get_by_day_and_time_frame(@day_being_shown, 30, @num_results_dqgs)
  end
end
