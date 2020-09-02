# frozen_string_literal: true

class Sites::QueryClicksController < Sites::AnalyticsController
  def show
    @query = request['query']
    @top_urls = top_urls
  end

  private

  def top_urls
    query = DateRangeTopNFieldQuery.new(@site.name,
                                        'click',
                                        @start_date,
                                        @end_date,
                                        'params.query.raw',
                                        @query,
                                        field: 'params.url',
                                        size: MAX_RESULTS)
    rtu_top_clicks = RtuTopClicks.new(query.body, @current_user.sees_filtered_totals?)
    rtu_top_clicks.top_n
  end
end
