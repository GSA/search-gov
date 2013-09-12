class Sites::ClickQueriesController < Sites::SetupSiteController
  def show
    @end_date = request["end_date"].to_date
    @start_date =  request["start_date"].to_date
    @url = request["url"]
    @top_queries = QueriesClicksStat.top_queries(@site.name, @url, @start_date, @end_date)
  end
end
