# frozen_string_literal: true

class Sites::ClickQueriesController < Sites::AnalyticsController
  def show
    @url = request['url']
    @top_queries = top_queries
  end

  private

  def top_queries
    query = DateRangeTopNFieldQuery.new(@site.name,
                                        'click',
                                        @start_date,
                                        @end_date,
                                        'params.url',
                                        @url,
                                        field: 'params.query.raw',
                                        size: MAX_RESULTS)
    rtu_top_clicks = RtuTopClicks.new(query.body, @current_user.sees_filtered_totals?)
    rtu_top_clicks.top_n
  end
end
