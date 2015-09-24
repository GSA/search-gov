class Sites::SetupDateRangeController < Sites::SetupSiteController
  before_filter :setup_date_range

  private

  def setup_date_range
    @end_date = request["end_date"].to_date
    @start_date = request["start_date"].to_date
  end
end
