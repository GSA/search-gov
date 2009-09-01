class Analytics::HomeController < ApplicationController
  layout "analytics"

  def index
    @yesterday_popular_terms = DailyQueryStat.popular_terms_over_days(1)
    @trailing_week_popular_terms = DailyQueryStat.popular_terms_over_days(7)
    @trailing_month_popular_terms = DailyQueryStat.popular_terms_over_days(30)
    @yesterday_biggest_movers = DailyQueryStat.biggest_mover_popularity_over_window(1)
    @weekly_biggest_movers = DailyQueryStat.biggest_mover_popularity_over_window(7)
    @monthly_biggest_movers = DailyQueryStat.biggest_mover_popularity_over_window(30)
  end
end