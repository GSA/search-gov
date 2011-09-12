class Affiliates::AnalyticsController < Affiliates::AffiliatesController
  before_filter :require_affiliate_or_admin
  before_filter :setup_affiliate
  before_filter :establish_aws_connection, :only => [:index, :monthly_reports]

  def index
    @title = "Query Logs - "
    @num_results_dqs = (request["num_results_dqs"] || "10").to_i
    @day_being_shown = request["day"].blank? ? DailyPopularQuery.most_recent_populated_date(@affiliate) : request["day"].to_date
    @most_recent_day_popular_terms = DailyPopularQuery.find_all_by_affiliate_id_and_day_and_time_frame_and_is_grouped(@affiliate.id, @day_being_shown, 1, false, :limit => @num_results_dqs, :order => 'times DESC')
    @trailing_week_popular_terms = DailyPopularQuery.find_all_by_affiliate_id_and_day_and_time_frame_and_is_grouped(@affiliate.id, @day_being_shown, 7, false, :limit => @num_results_dqs, :order => 'times DESC')
    @trailing_month_popular_terms = DailyPopularQuery.find_all_by_affiliate_id_and_day_and_time_frame_and_is_grouped(@affiliate.id, @day_being_shown, 30, false, :limit => @num_results_dqs, :order => 'times DESC')
    @start_date = 1.month.ago.to_date
    @end_date = Date.yesterday
  end

  def monthly_reports
    @title = "Monthly Reports - "
    @most_recent_date = DailyUsageStat.most_recent_populated_date(@affiliate.name) || Date.current
    @report_date = params[:date].blank? ? Date.yesterday : Date.civil(params[:date][:year].to_i, params[:date][:month].to_i)
    @monthly_totals = DailyUsageStat.monthly_totals(@report_date.year, @report_date.month, @affiliate.name)
    @total_clicks = DailySearchModuleStat.where(:day => @report_date.beginning_of_month..@report_date.end_of_month, :affiliate_name=> @affiliate.name).sum(:clicks)
  end

  def query_search
    @title = "Query Search - "
    @search_query_term = params["query"]
    @start_date = Date.parse(params["analytics_search_start_date"]) rescue 1.month.ago.to_date
    @end_date = Date.parse(params["analytics_search_end_date"]) rescue Date.yesterday
    @search_results = DailyQueryStat.query_counts_for_terms_like(@search_query_term, @start_date, @end_date, @affiliate.name)
  end
end
