class Analytics::HomeController < Analytics::AnalyticsController
  MAX_NUMBER_OF_NO_RESULTS_TO_SHOW = 21
  before_filter :establish_aws_connection, :only => [:queries]

  def index
  end

  def queries
    @page_title = 'Queries'
    @num_results_dqs = (request["num_results_dqs"] || "10").to_i
    @available_dates = DailyQueryStat.available_dates_range
    @end_date = request["end_date"].blank? ? DailyQueryStat.most_recent_populated_date : request["end_date"].to_date
    @start_date = request["start_date"].blank? ? @end_date : request["start_date"].to_date
    @no_results_queries = DailyQueryNoresultsStat.most_popular_no_results_queries(@start_date, @end_date, MAX_NUMBER_OF_NO_RESULTS_TO_SHOW, Affiliate::USAGOV_AFFILIATE_NAME)
    @popular_terms = DailyQueryStat.most_popular_terms(@start_date, @end_date, @num_results_dqs, Affiliate::USAGOV_AFFILIATE_NAME)
  end
end
