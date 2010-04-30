class Analytics::HomeController < Analytics::AnalyticsController
  before_filter :day_being_show
  
  def index
    @num_results_qas = (request["num_results_qas"] || "10").to_i
    @num_results_dqs = (request["num_results_dqs"] || "10").to_i
    @most_recent_day_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 1, @num_results_dqs)
    @trailing_week_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 7, @num_results_dqs)
    @trailing_month_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 30, @num_results_dqs)
    @most_recent_day_biggest_movers = MovingQuery.biggest_movers(@day_being_shown, 1, @num_results_qas)
    @weekly_biggest_movers = MovingQuery.biggest_movers(@day_being_shown, 7, @num_results_qas)
    @monthly_biggest_movers = MovingQuery.biggest_movers(@day_being_shown, 30, @num_results_qas)    
  end
  
  def daily_top_queries
    @count = (params[:count] || 1000).to_i
    @site_locale = params[:site_locale] || I18n.default_locale.to_s 
    @top_queries = DailyQueryStat.most_popular_terms(@day_being_shown, 1, @count, DailyQueryStat::DEFAULT_AFFILIATE_NAME, @site_locale)
    if @top_queries.is_a?(String)
      @top_queries = []
    end
    csv_string = FasterCSV.generate do |csv|
      csv << ["Query", "Count"]
      @top_queries.each do |top_query|
        csv << [top_query.query, top_query.times]
      end
    end
    @filename = "daily_top_queries_#{@day_being_shown.to_s}_#{@site_locale}.csv"
    send_data(csv_string, :type => 'text/csv', :filename => @filename)
  end
    
  private
  
  def day_being_show
    @day_being_shown = request["day"].nil? ? DailyQueryStat.most_recent_populated_date : request["day"].to_date
  end
end