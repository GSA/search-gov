class Analytics::HomeController < ApplicationController
  layout "analytics"

  def index
    @num_results1 = (request["num_results1"] || "10").to_i
    @num_results7 = (request["num_results7"] || "10").to_i
    @num_results30 = (request["num_results30"] || "10").to_i
    @day_being_shown = request["day"].nil? ? DailyQueryStat.most_recent_populated_date : request["day"].to_date
    @most_recent_day_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 1, @num_results1)
    @trailing_week_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 7, @num_results7)
    @trailing_month_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 30, @num_results30)
    @most_recent_day_biggest_movers = DailyQueryStat.biggest_movers(@day_being_shown, 1, @num_results1)
    @weekly_biggest_movers = DailyQueryStat.biggest_movers(@day_being_shown, 7, @num_results7)
    @monthly_biggest_movers = DailyQueryStat.biggest_movers(@day_being_shown, 30, @num_results30)
  end
end