class Affiliates::AnalyticsController < Affiliates::AffiliatesController
  before_filter :require_affiliate_or_admin
  before_filter :setup_affiliate
  before_filter :establish_aws_connection, :only => [:index, :monthly_reports]

  def index
    @title = "Query Logs - "
    @num_results_dqs = (request["num_results_dqs"] || "10").to_i
    @day_being_shown = request["day"].nil? ? DailyQueryStat.most_recent_populated_date(@affiliate.name) : request["day"].to_date
    @most_recent_day_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 1, @num_results_dqs, @affiliate.name)
    @trailing_week_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 7, @num_results_dqs, @affiliate.name)
    @trailing_month_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 30, @num_results_dqs, @affiliate.name)
    @start_date = 1.month.ago.to_date
    @end_date = Date.yesterday
  end

  def monthly_reports
    @title = "Monthly Reports - "
    @most_recent_date = DailyUsageStat.most_recent_populated_date(@affiliate.name) || Date.today
    @report_date = params[:date].blank? ? Date.yesterday : Date.civil(params[:date][:year].to_i, params[:date][:month].to_i)
    @monthly_totals = DailyUsageStat.monthly_totals(@report_date.year, @report_date.month, @affiliate.name)
    @total_clicks = Click.monthly_totals_for_affiliate(@report_date.year, @report_date.month, @affiliate.name)
  end

  def query_search
    @search_query_term = params["query"]
    @start_date = Date.parse(params["analytics_search_start_date"]) rescue 1.month.ago.to_date
    @end_date = Date.parse(params["analytics_search_end_date"]) rescue Date.yesterday
    @search_results = DailyQueryStat.query_counts_for_terms_like(@search_query_term, @start_date, @end_date, @affiliate.name)
  end
end
