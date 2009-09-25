class Analytics::TimelineController < Analytics::AnalyticsController
  def show
    @query = params["query"]
    @query_group = QueryGroup.find_by_name(@query) if params["grouped"]
    timeline = Timeline.new(@query, params["grouped"])
    @dates = timeline.dates
    @series = timeline.series
  end
end