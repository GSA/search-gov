class Affiliates::TimelineController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate

  def show
    @title = 'Query Timeline - '
    @query = params[:query]
    @comparison_query = params[:comparison_query]
    @timelines = []
    @timelines << Timeline.load_affiliate_daily_query_stats(@query, @affiliate.name)
    @timelines << Timeline.load_affiliate_daily_query_stats(@comparison_query, @affiliate.name) if @comparison_query
    @zoom_start_time = @timelines.first.dates.last.advance(:months => -1)
  end
end
