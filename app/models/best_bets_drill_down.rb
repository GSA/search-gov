class BestBetsDrillDown
  attr_reader :module_name

  def initialize(site, module_tag)
    @site = site
    @module = SearchModule.find_by_tag module_tag
    @module_name = @module.display_name
  end

  def search_module_stats
    impressions_by_best_bet = counts(:impressions)
    clicks_by_best_bet = counts(:clicks)
    build_stats(impressions_by_best_bet, clicks_by_best_bet)
  end

  private
  def build_stats(impressions, clicks)
    stats = impressions.collect do |model_id, impression_count|
      hash = build_hash(model_id, impression_count, clicks[model_id] || 0)
      hash.present? ? [model_id, hash] : nil
    end
    sorted_stats = stats.compact.sort_by { |k, stats_hash| -stats_hash[:clickthru_ratio] }
    Hash[sorted_stats]
  end

  def build_hash(model_id, impression_count, click_count)
    klass = BestBetType.get_klass @module.tag
    clickthru_ratio = (100.0 * click_count / impression_count) rescue 0.0
    { model: klass.find(model_id), impression_count: impression_count, click_count: click_count, clickthru_ratio: clickthru_ratio }
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error e
    nil
  end

  def counts(field)
    filters = [eq_filter('affiliate_id', @site.id), eq_filter('module', @module.tag)]
    query_hash = { :timeframe => 'this_month', :group_by => 'model_id', :filters => filters }
    ActiveSupport::Notifications.instrument("best_bets_drill_down.usasearch", :query => query_hash) do
      counts = Keen.count(field, query_hash)
      Hash[counts.collect(&:values).map { |model_id, cnt| [model_id.to_i, cnt.to_i] }]
    end
  end

  def eq_filter(name, value)
    { :property_name => name, :operator => 'eq', :property_value => value }
  end

end
