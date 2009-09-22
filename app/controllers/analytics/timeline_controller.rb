class Analytics::TimelineController < Analytics::AnalyticsController
  def show
    @query = params["query"]
    timeline = Timeline.new(@query)
    @dates = timeline.dates
    @series = timeline.series
  end
end