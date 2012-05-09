class Admin::AffiliateReportsController < Admin::AdminController

  def index
    @page_title = 'Affiliate Reports'
    @report_date = params[:date].blank? ? Date.yesterday : Date.civil(params[:date][:year].to_i, params[:date][:month].to_i)
    @affiliate_total_queries = DailyUsageStat.sum(:total_queries, :conditions => ['day BETWEEN ? AND ?', @report_date.beginning_of_month, @report_date.end_of_month], :group => :affiliate, :order => '1 DESC', :distinct => :affiliate)
  end
end