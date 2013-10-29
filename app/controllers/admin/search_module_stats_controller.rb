class Admin::SearchModuleStatsController < Admin::AdminController
  def index
    @page_title = 'Search Module Stats'
    @affiliate_picklist = Affiliate.select(:name).order(:name).collect{|aff| [aff.name, aff.name]}
    return unless @end_date = request["end_date"].blank? ? DailySearchModuleStat.most_recent_populated_date : request["end_date"].to_date
    @start_date = request["start_date"].blank? ? @end_date.beginning_of_month : request["start_date"].to_date
    @affiliate_pick = request["affiliate_pick"].blank? ? nil : request["affiliate_pick"]
    @vertical_pick = request["vertical_pick"].blank? ? nil : request["vertical_pick"]
    module_stats_analytics = ModuleStatsAnalytics.new(@start_date..@end_date, @affiliate_pick, @vertical_pick)
    @search_module_stats = module_stats_analytics.module_stats
  end
end
