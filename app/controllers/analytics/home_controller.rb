class Analytics::HomeController < Analytics::AnalyticsController
  MAX_NUMBER_OF_BIG_MOVERS_TO_SHOW = 21
  before_filter :day_being_shown, :establish_aws_connection

  def index
    @num_results_dqs = (request["num_results_dqs"] || "10").to_i
    @num_results_dqgs = (request["num_results_dqgs"] || "10").to_i
    @most_recent_day_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 1, @num_results_dqs)
    @trailing_week_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 7, @num_results_dqs)
    @trailing_month_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 30, @num_results_dqs)
    @most_recent_day_popular_query_groups = DailyQueryStat.most_popular_query_groups(@day_being_shown, 1, @num_results_dqgs)
    @trailing_week_popular_query_groups = DailyQueryStat.most_popular_query_groups(@day_being_shown, 7, @num_results_dqgs)
    @trailing_month_popular_query_groups = DailyQueryStat.most_popular_query_groups(@day_being_shown, 30, @num_results_dqgs)
    @most_recent_day_biggest_movers = MovingQuery.biggest_movers(@day_being_shown, MAX_NUMBER_OF_BIG_MOVERS_TO_SHOW)
  end

  private

  def day_being_shown
    @day_being_shown = request["day"].nil? ? DailyQueryStat.most_recent_populated_date : request["day"].to_date
  end
end