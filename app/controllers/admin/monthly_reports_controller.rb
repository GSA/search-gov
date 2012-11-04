class Admin::MonthlyReportsController < Admin::AdminController
  before_filter :establish_aws_connection

  def index
    @page_title = 'Monthly Reports'
    @affiliate_picklist = Affiliate.select(:name).order(:name).collect{|aff| [aff.name, aff.name]}
    @affiliate_pick = request["affiliate_pick"].blank? ? nil : request["affiliate_pick"]
    @report_date = params[:date].blank? ? Date.yesterday : Date.civil(params[:date][:year].to_i, params[:date][:month].to_i)
    @affiliate = Affiliate.find_by_name(@affiliate_pick)
    @most_recent_date = @affiliate ? DailyUsageStat.most_recent_populated_date(@affiliate.name) || Date.current : Date.current
    @monthly_totals = DailyUsageStat.monthly_totals(@report_date.year, @report_date.month, @affiliate_pick)
    conditions = {:day => @report_date.beginning_of_month..@report_date.end_of_month}
    conditions.merge!(:affiliate_name => @affiliate_pick) unless @affiliate_pick.blank?
    @total_clicks = DailySearchModuleStat.where(conditions).sum(:clicks)
    @affiliate_report_name = @affiliate_pick || '_all_'
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Date')
    data_table.new_column('number', "Total Query Usage")
    rows = DailyUsageStat.sum(:total_queries, :group => "date_format(day,'%Y-%m')" ).to_a
    data_table.add_rows(rows)
    options = {width: 750, height: 300, title: 'Query Totals by Month'}
    @chart = GoogleVisualr::Interactive::AreaChart.new(data_table, options)
  end
end