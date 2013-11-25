class Admin::AffiliateReportsController < Admin::AdminController

  def index
    @page_title = 'Customer Reports'
    @report_date = params[:date].blank? ? Date.yesterday : Date.civil(params[:date][:year].to_i, params[:date][:month].to_i)
    @affiliate_total_queries = DailyUsageStat.total_queries(@report_date.beginning_of_month, @report_date.end_of_month)
  end
end
