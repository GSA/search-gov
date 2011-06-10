class Analytics::SearchModulesController < Analytics::AnalyticsController
  def index
    @page_title = 'Search Module Stats'
    @day_being_shown = request["day"].blank? ? DailySearchModuleStat.most_recent_populated_date : request["day"].to_date
    @search_module_stats = DailySearchModuleStat.module_stats_for_day(@day_being_shown)
  end
end
