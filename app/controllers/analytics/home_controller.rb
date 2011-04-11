class Analytics::HomeController < Analytics::AnalyticsController
  MAX_NUMBER_OF_BIG_MOVERS_TO_SHOW = 21
  MAX_NUMBER_OF_NO_RESULTS_TO_SHOW = 21
  before_filter :establish_aws_connection, :only => [:queries]

  def index
  end

  def queries
    @page_title = 'Queries'
    @day_being_shown = request["day"].blank? ? DailyPopularQuery.most_recent_populated_date : request["day"].to_date
    @num_results_dqs = (request["num_results_dqs"] || "10").to_i
    @num_results_dqgs = (request["num_results_dqgs"] || "10").to_i
    @most_recent_day_popular_terms = DailyPopularQuery.find_all_by_day_and_time_frame(@day_being_shown, 1, false, :limit => @num_results_dqs, :order => 'times DESC')
    @trailing_week_popular_terms = DailyPopularQuery.find_all_by_day_and_time_frame(@day_being_shown, 7, false, :limit => @num_results_dqs, :order => 'times DESC')
    @trailing_month_popular_terms = DailyPopularQuery.find_all_by_day_and_time_frame_and_is_grouped(@day_being_shown, 30, false, :limit => @num_results_dqs, :order => 'times DESC')
    @most_recent_day_popular_query_groups = DailyPopularQuery.find_all_by_day_and_time_frame_and_is_grouped(@day_being_shown, 1, true, :limit => @num_results_dqgs, :order => 'times DESC')
    @trailing_week_popular_query_groups = DailyPopularQuery.find_all_by_day_and_time_frame_and_is_grouped(@day_being_shown, 7, true, :limit => @num_results_dqgs, :order => 'times DESC')
    @trailing_month_popular_query_groups = DailyPopularQuery.find_all_by_day(@day_being_shown, :conditions => ['time_frame=? AND is_grouped=?', 30, true], :limit => @num_results_dqgs, :order => 'times DESC')
    @most_recent_day_biggest_movers = MovingQuery.biggest_movers(@day_being_shown, MAX_NUMBER_OF_BIG_MOVERS_TO_SHOW)
    @most_recent_day_no_results_queries = DailyQueryNoresultsStat.no_results_queries(@day_being_shown, MAX_NUMBER_OF_NO_RESULTS_TO_SHOW)
    @contextual_query_total = DailyContextualQueryTotal.total_for(@day_being_shown)
    @start_date = 1.month.ago.to_date
    @end_date = Date.yesterday
  end
end
