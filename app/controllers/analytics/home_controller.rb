class Analytics::HomeController < ApplicationController
  layout "analytics"

  def index
    @most_recent_day_popular_terms = DailyQueryStat.popular_terms_over_days(1)
    @trailing_week_popular_terms = DailyQueryStat.popular_terms_over_days(7)
    @trailing_month_popular_terms = DailyQueryStat.popular_terms_over_days(30)
    @most_recent_day_biggest_movers = DailyQueryStat.biggest_mover_popularity_over_window(1)
    @weekly_biggest_movers = DailyQueryStat.biggest_mover_popularity_over_window(7)
    @monthly_biggest_movers = DailyQueryStat.biggest_mover_popularity_over_window(30)
    @most_recent_day = DailyQueryStat.most_recent_populated_date
  end
end