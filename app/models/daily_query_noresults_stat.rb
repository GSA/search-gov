class DailyQueryNoresultsStat < ActiveRecord::Base
  validates_presence_of :day, :query, :times, :affiliate, :locale
  validates_uniqueness_of :query, :scope => [:day, :affiliate, :locale]

  def self.no_results_queries(target_date, num_results, affiliate_name = Affiliate::USAGOV_AFFILIATE_NAME, locale = I18n.default_locale.to_s)
    find_all_by_day_and_affiliate_and_locale(target_date, affiliate_name, locale, :order=>"times DESC", :limit => num_results).
      collect { |res| QueryCount.new(res.query, res.times) }
  end
end
