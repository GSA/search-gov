class Analytics::TimelineController < Analytics::AnalyticsController

  def show
    @query, @comparison_query = params["query"], params["comparison_query"] || nil
    @query_group = QueryGroup.find_by_name(@query) if params["grouped"]
    @timelines = []
    @timelines << Timeline.new(@query, params["grouped"])
    @timelines << Timeline.new(@comparison_query, nil) if @comparison_query
  end
end