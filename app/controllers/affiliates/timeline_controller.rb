class Affiliates::TimelineController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate

  def show
    @title = 'Query Timeline - '
    @query = params[:query]
    @comparison_query = params[:comparison_query]
    query_timeline = Timeline.load_affiliate_daily_query_stats(@query, @affiliate.name)
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('date', 'Date')
    data_table.new_column('number', @query)
    if @comparison_query
      data_table.new_column('number', @comparison_query)
      comparison_query_timeline = Timeline.load_affiliate_daily_query_stats(@comparison_query, @affiliate.name)
      rows = query_timeline.dates.zip(query_timeline.series, comparison_query_timeline.series)
    else
      rows = query_timeline.dates.zip(query_timeline.series)
    end
    data_table.add_rows(rows)
    options = {width: 750, height: 300, title: 'Query Totals by Date'}
    @chart = GoogleVisualr::Interactive::LineChart.new(data_table, options)
  end
end
