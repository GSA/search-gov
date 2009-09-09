class Analytics::HomeController < ApplicationController
  layout "analytics"

  def index
    @num_results = (request["num_results"] || "10").to_i
    @most_recent_day_popular_terms = DailyQueryStat.popular_terms_over_days(1, @num_results)
    @trailing_week_popular_terms = DailyQueryStat.popular_terms_over_days(7, @num_results)
    @trailing_month_popular_terms = DailyQueryStat.popular_terms_over_days(30, @num_results)
    @most_recent_day_biggest_movers = DailyQueryStat.biggest_mover_popularity_over_window(1, @num_results)
    @weekly_biggest_movers = DailyQueryStat.biggest_mover_popularity_over_window(7, @num_results)
    @monthly_biggest_movers = DailyQueryStat.biggest_mover_popularity_over_window(30, @num_results)
    @most_recent_day = DailyQueryStat.most_recent_populated_date
  end
end