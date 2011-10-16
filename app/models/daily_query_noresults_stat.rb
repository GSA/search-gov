class DailyQueryNoresultsStat < ActiveRecord::Base
  validates_presence_of :day, :query, :times, :affiliate, :locale
  validates_uniqueness_of :query, :scope => [:day, :affiliate, :locale]

  def self.most_popular_no_results_queries(start_date, end_date, num_results, affiliate_name = Affiliate::USAGOV_AFFILIATE_NAME, locale = I18n.default_locale.to_s)
    sum(:times,
        :group => :query,
        :conditions => ['day between ? AND ? AND affiliate = ? AND locale = ?', start_date, end_date, affiliate_name, locale],
        :order => "sum_times desc",
        :limit => num_results).
      collect { |hash| QueryCount.new(hash.first, hash.last) }
  end

end
