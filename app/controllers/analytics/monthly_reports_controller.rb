class Analytics::MonthlyReportsController < Analytics::AnalyticsController
  before_filter :set_report_date

  def index
    @monthly_totals = DailyUsageStat.monthly_totals(@report_date.year, @report_date.month)
  end

  def top_queries
    @top_queries = DailyQueryStat.find(:all, :select => 'DISTINCT query, SUM(times) as total', :conditions => ['day BETWEEN ? AND ? AND affiliate=?', @report_date.beginning_of_month, @report_date.end_of_month, 'usasearch.gov'], :group => 'query', :order => 'total desc', :limit => '20000')
    csv_string = FasterCSV.generate do |csv|
      csv << ["Query", "Count"]
      @top_queries.each do |top_query|
        csv << [top_query.query, top_query.total]
      end
    end
    @filename = "top_queries_#{@report_date.strftime('%Y%m')}.csv"
    send_data(csv_string, :type => 'text/csv', :filename => @filename)
  end
  
  private

  def set_report_date
    @today = Date.today
    @report_date = params[:date].blank? ? @today : Date.civil(params[:date][:year].to_i, params[:date][:month].to_i)
  end
end