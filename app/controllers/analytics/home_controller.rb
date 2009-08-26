class Analytics::HomeController < ApplicationController
  layout "analytics"

  def index
    @yesterday_popular_terms = DailyQueryStat.popular_terms_over_days(1)
    @trailing_week_popular_terms = DailyQueryStat.popular_terms_over_days(7)
    @trailing_month_popular_terms = DailyQueryStat.popular_terms_over_days(30)
  end
end