class DailyQueryStat < ActiveRecord::Base
  @queue = :usasearch
  validates_presence_of :day, :query, :times, :affiliate, :locale
  validates_uniqueness_of :query, :scope => [:day, :affiliate, :locale]
  before_save :squish_query
  RESULTS_SIZE = 10
  INSUFFICIENT_DATA = "Not enough historic data to compute most popular"
  MAX_ORPHANS_PER_PASS = 250000

  searchable do
    text :query
    string :affiliate
    string :locale
    time :day
  end

  class << self
    def reindex_day(day)
      Resque.enqueue(DailyQueryStat, day)
    end

    def perform(day_string)
      day = Date.parse(day_string)
      bulk_remove_solr_records_for_day(day)
      Sunspot.index!(all(:conditions=>["day=?", day]))
    end

    def bulk_remove_solr_records_for_day(day)
      datetime = day.beginning_of_day
      Sunspot.remove(DailyQueryStat) { with(:day).between(datetime..(datetime + 1.day)) }
      Sunspot.commit
    end

    def search_for(query, start_date = 1.year.ago, end_date = Date.current, affiliate_name = Affiliate::USAGOV_AFFILIATE_NAME, locale = I18n.default_locale.to_s, per_page = 3000)
      solr_search_ids do
        with :affiliate, affiliate_name
        with :locale, locale
        with(:day).between(start_date..end_date)
        keywords query
        paginate :page => 1, :per_page => per_page
      end rescue nil
    end

    def query_counts_for_terms_like(query, start_date = 1.year.ago, end_date = Date.current, affiliate_name = Affiliate::USAGOV_AFFILIATE_NAME, locale = I18n.default_locale.to_s)
      unless query.blank?
        solr_search_result_ids = search_for(query, start_date, end_date, affiliate_name, locale, 50000)
        return sum(:times,
                   :group => :query,
                   :conditions => "id in (#{solr_search_result_ids.join(',')})",
                   :order => "sum_times desc") unless solr_search_result_ids.empty?
      end
      return []
    end

    def reversed_backfilled_series_since_2009_for(query, up_to_day = Date.yesterday.to_date)
      timeline = Timeline.new(query, nil, nil, Date.new(2009, 1, 1))
      ary = []
      timeline.dates.each_with_index do |day, idx|
        ary << timeline.series[idx].y if day <= up_to_day
      end
      ary.reverse
    end

    def most_popular_terms(start_date, end_date, num_results = RESULTS_SIZE, affiliate_name = Affiliate::USAGOV_AFFILIATE_NAME, locale = I18n.default_locale.to_s)
      return INSUFFICIENT_DATA if end_date.nil? or start_date.nil?
      results = sum(:times,
                    :group => :query,
                    :conditions => ['day between ? AND ? AND affiliate = ? AND locale = ?', start_date, end_date, affiliate_name, locale],
                    :having => "sum_times > #{ affiliate_name == Affiliate::USAGOV_AFFILIATE_NAME ? "3" : "0"}",
                    :joins => 'FORCE INDEX (ad)',
                    :order => "sum_times desc",
                    :limit => num_results)
      return INSUFFICIENT_DATA if results.empty?
      results.collect { |hash| QueryCount.new(hash.first, hash.last) }
    end

    def most_popular_terms_for_year_month(year, month, num_results = RESULTS_SIZE)
      start_date = Date.civil(year, month, 1)
      end_date = Date.civil(year, month, -1)
      results = sum(:times,
                    :group => :query,
                    :conditions => ['day between ? AND ?', start_date, end_date],
                    :joins => 'FORCE INDEX (da)',
                    :order => "sum_times desc",
                    :limit => num_results)
      return INSUFFICIENT_DATA if results.empty?
      results.collect { |hash| QueryCount.new(hash.first, hash.last) }
    end

    def most_popular_groups_for_year_month(year, month, num_results = RESULTS_SIZE)
      start_date = Date.civil(year, month, 1)
      end_date = Date.civil(year, month, -1)
      results = find_by_sql ["select q.name, sum(d.times) cnt from daily_query_stats d, query_groups q, grouped_queries g, grouped_queries_query_groups b "+
                               "where day between ? AND ? and d.query = g.query and q.id = b.query_group_id and g.id = b.grouped_query_id "+
                               "group by q.name order by cnt desc limit ?", start_date, end_date, num_results]
      return INSUFFICIENT_DATA if results.empty?
      results.collect { |res| QueryCount.new(res.name, res.cnt, true) }
    end

    def most_popular_query_groups(end_date, days_back, num_results = RESULTS_SIZE, affiliate_name = Affiliate::USAGOV_AFFILIATE_NAME, locale = I18n.default_locale.to_s)
      return INSUFFICIENT_DATA if end_date.nil?
      start_date = end_date - days_back.days + 1.day
      results = find_by_sql ["select q.name, sum(d.times) cnt from daily_query_stats d, query_groups q, grouped_queries g, grouped_queries_query_groups b "+
                               "where day between ? AND ? AND affiliate = ? AND locale = ? and d.query = g.query and q.id = b.query_group_id and g.id = b.grouped_query_id "+
                               "group by q.name order by cnt desc limit ?", start_date, end_date, affiliate_name, locale, num_results]
      return INSUFFICIENT_DATA if results.empty?
      results.collect { |res| QueryCount.new(res.name, res.cnt, true) }
    end

    def most_recent_populated_date(affiliate_name = Affiliate::USAGOV_AFFILIATE_NAME)
      maximum(:day, :conditions => ['affiliate = ?', affiliate_name])
    end

    def least_recent_populated_date(affiliate_name = Affiliate::USAGOV_AFFILIATE_NAME)
      minimum(:day, :conditions => ['affiliate = ?', affiliate_name])
    end

    def available_dates_range(affiliate_name = Affiliate::USAGOV_AFFILIATE_NAME)
      if (lrpd = least_recent_populated_date(affiliate_name))
        lrpd..most_recent_populated_date(affiliate_name)
      else
        Date.yesterday..Date.yesterday
      end
    end

    def collect_query_group_named(name, start_date)
      queries = QueryGroup.find_by_name(name).grouped_queries.collect { |gq| gq.query }
      generic_collection(["day >= ? AND query IN (?)", start_date, queries])
    end

    def collect_query(query, start_date)
      generic_collection(["day >= ? AND query = ?", start_date, query])
    end

    def collect_affiliate_query(query, affiliate_name, start_date)
      generic_collection(["day >= ? AND affiliate = ? AND query = ?", start_date, affiliate_name, query])
    end

    def generic_collection(conditions)
      results = sum(:times, :group => :day, :conditions => conditions, :order => "day")
      dqs=[]
      results.each_pair { |day, times| dqs << new(:day=> day, :times => times) }
      dqs
    end
  end

  private

  def squish_query
    self.query.squish!
  end
end
