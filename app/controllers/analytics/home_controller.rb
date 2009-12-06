class Analytics::HomeController < Analytics::AnalyticsController
  
  def index
    @num_results_qas = (request["num_results_qas"] || "10").to_i
    @num_results_dqs = (request["num_results_dqs"] || "10").to_i
    @day_being_shown = request["day"].nil? ? DailyQueryStat.most_recent_populated_date : request["day"].to_date
    @most_recent_day_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 1, @num_results_dqs)
    @trailing_week_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 7, @num_results_dqs)
    @trailing_month_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 30, @num_results_dqs)
    @most_recent_day_biggest_movers = MovingQuery.biggest_movers(@day_being_shown, 1, @num_results_qas)
    @weekly_biggest_movers = MovingQuery.biggest_movers(@day_being_shown, 7, @num_results_qas)
    @monthly_biggest_movers = MovingQuery.biggest_movers(@day_being_shown, 30, @num_results_qas)
  end
end