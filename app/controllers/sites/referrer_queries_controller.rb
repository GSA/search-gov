# frozen_string_literal: true

class Sites::ReferrerQueriesController < Sites::AnalyticsController
  def show
    @url = params['url']
    @top_queries = top_queries
  end

  private

  def top_queries
    query = DateRangeTopNFieldQuery.new(@site.name,
                                        'search',
                                        @start_date,
                                        @end_date,
                                        'referrer',
                                        @url,
                                        field: 'params.query.raw',
                                        size: MAX_RESULTS)
    rtu_top_queries = RtuTopQueries.new(query.body)
    rtu_top_queries.top_n
  end
end
