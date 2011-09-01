class Analytics::SearchModulesController < Analytics::AnalyticsController
  def index
    @page_title = 'Search Module Stats'
    @affiliate_picklist = Affiliate.select(:name).order(:name).collect{|aff| [aff.name, aff.name]}.insert(0,['usasearch.gov','usasearch.gov'])
    return unless @end_date = request["end_date"].blank? ? DailySearchModuleStat.most_recent_populated_date : request["end_date"].to_date
    @start_date = request["start_date"].blank? ? @end_date.beginning_of_month : request["start_date"].to_date
    @locale_pick = request["locale_pick"].blank? ? nil : request["locale_pick"]
    @affiliate_pick = request["affiliate_pick"].blank? ? nil : request["affiliate_pick"]
    @vertical_pick = request["vertical_pick"].blank? ? nil : request["vertical_pick"]
    @search_module_stats = DailySearchModuleStat.
      module_stats_for_daterange_and_affiliate_and_locale(@start_date..@end_date, @affiliate_pick, @locale_pick, @vertical_pick)
  end
end
