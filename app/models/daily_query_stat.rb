class DailyQueryStat < ActiveRecord::Base
  extend Resque::Plugins::Priority
  @queue = :primary
  validates_presence_of :day, :query, :times, :affiliate
  validates_uniqueness_of :query, :scope => [:day, :affiliate]
  before_save :squish_query
  RESULTS_SIZE = 10
  INSUFFICIENT_DATA = "Not enough historic data to compute most popular"

  searchable do
    text :query
    string :affiliate
    time :day
  end

  class << self
    def reindex_day(day)
      sum(:times, :group => :affiliate, :conditions=> ["day = ?", day], :order => "sum_times desc").each do | dqs |
        Resque.enqueue(DailyQueryStat, day, dqs[0])
      end
    end

    def perform(day_string, affiliate_name)
      day = Date.parse(day_string)
      bulk_remove_solr_records_for_day_and_affiliate(day, affiliate_name)
      Sunspot.index(all(:conditions=>["day=? and affiliate = ?", day, affiliate_name]))
    end

    def bulk_remove_solr_records_for_day_and_affiliate(day, affiliate_name)
      starttime, endtime = day.beginning_of_day, day.end_of_day
      Sunspot.remove(DailyQueryStat) do
        with(:day).between(starttime..endtime)
        with(:affiliate, affiliate_name)
      end
    end

    def search_for(query, affiliate_name, start_date = 1.year.ago, end_date = Date.current, per_page = 3000)
      solr_search_ids do
        with :affiliate, affiliate_name
        with(:day).between(start_date..end_date)
        keywords query
        paginate :page => 1, :per_page => per_page
      end rescue nil
    end

    def query_counts_for_terms_like(query, affiliate_name, start_date = 1.year.ago, end_date = Date.current)
      unless query.blank?
        solr_search_result_ids = search_for(query, affiliate_name, start_date, end_date, 50000)
        return sum(:times,
                   :group => :query,
                   :conditions => "id in (#{solr_search_result_ids.join(',')})",
                   :order => "sum_times desc") unless solr_search_result_ids.empty?
      end
      []
    end

    def most_popular_terms(affiliate_name, start_date, end_date, num_results = RESULTS_SIZE)
      return INSUFFICIENT_DATA if end_date.nil? or start_date.nil?
      results = sum(:times,
                    :group => :query,
                    :conditions => ['day between ? AND ? AND affiliate = ?', start_date, end_date, affiliate_name],
                    :having => "sum_times > 0",
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

    def most_recent_populated_date(affiliate_name)
      maximum(:day, :conditions => ['affiliate = ?', affiliate_name])
    end

    def least_recent_populated_date(affiliate_name)
      minimum(:day, :conditions => ['affiliate = ?', affiliate_name])
    end

    def available_dates_range(affiliate_name)
      if (lrpd = least_recent_populated_date(affiliate_name))
        lrpd..most_recent_populated_date(affiliate_name)
      else
        Date.yesterday..Date.yesterday
      end
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
