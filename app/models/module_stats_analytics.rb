class ModuleStatsAnalytics
  require "ostruct"
  SPARKLINE_MONTHS_TO_SHOW = 2
  CTR = '100.0*sum(clicks)/sum(impressions) ctr'
  CTR_QUERY = "day, #{CTR}"

  def initialize(daterange, affiliate_name = nil, vertical = nil)
    @daterange = daterange
    @conditions = { day: @daterange }
    @conditions.merge!(affiliate_name: affiliate_name) if affiliate_name
    @conditions.merge!(vertical: vertical) if vertical
  end

  def module_stats
    total_clicks, total_impressions = 0, 0

    results = clicks_and_impressions
    global_results_hash = global_ctrs

    stats = results.collect do |stat|
      total_clicks += stat.clicks
      total_impressions += stat.impressions
      build_struct(stat, global_results_hash[stat.module_tag])
    end.compact

    if stats.present?
      stats << OpenStruct.new(display_name: "Total", clicks: total_clicks, impressions: total_impressions,
                              clickthru_ratio: clickthru_ratio(total_clicks, total_impressions), historical_ctr: historical_ctr)
    end

    stats
  end

  private

  def historical_ctr
    DailySearchModuleStat.select(CTR_QUERY).where(@conditions.merge(day: sparkline_range)).group(:day).collect(&:ctr)
  end

  def sparkline_range
    @daterange.last-SPARKLINE_MONTHS_TO_SHOW.month..@daterange.last
  end

  def build_struct(stat, average_clickthru_ratio)
    merged_conditions = @conditions.merge(module_tag: stat.module_tag, day: sparkline_range)
    historical_ctr = DailySearchModuleStat.select(CTR_QUERY).where(merged_conditions).group(:day).map { |r| r.ctr }
    OpenStruct.new(display_name: stat.display_name, clicks: stat.clicks, impressions: stat.impressions,
                   clickthru_ratio: clickthru_ratio(stat.clicks, stat.impressions), historical_ctr: historical_ctr,
                   average_clickthru_ratio: average_clickthru_ratio)
  end

  def global_ctrs
    global_results = DailySearchModuleStat.select("module_tag, #{CTR}").where(day: @daterange).group(:module_tag)
    Hash[global_results.map { |result| [result.module_tag, result.ctr] }]
  end

  def clicks_and_impressions
    DailySearchModuleStat.select('module_tag, display_name, SUM(clicks) AS clicks, SUM(impressions) AS impressions').
        where(@conditions).group(:module_tag).order("clicks DESC").joins(:search_module)
  end

  def clickthru_ratio(clicks, impressions)
    100.0 * clicks / impressions
  end
end