class DailyQueryStat < ActiveRecord::Base
  extend AffiliateDailyStats
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
      sum(:times, :group => :affiliate, :conditions => ["day = ?", day], :order => "sum_times desc").each do |dqs|
        Resque.enqueue(DailyQueryStat, day, dqs[0])
      end
    end

    def perform(day_string, affiliate_name)
      day = Date.parse(day_string)
      bulk_remove_solr_records_for_day_and_affiliate(day, affiliate_name)
      Sunspot.index(all(:conditions => ["day=? and affiliate = ?", day, affiliate_name]))
    end

    def bulk_remove_solr_records_for_day_and_affiliate(day, affiliate_name)
      starttime, endtime = day.beginning_of_day, day.end_of_day
      Sunspot.remove(DailyQueryStat) do
        with(:day).between(starttime..endtime)
        with(:affiliate, affiliate_name)
      end
    end

    def prune_before(time)
      Sunspot.remove(DailyQueryStat) do
        with(:day).less_than(time)
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

    def trending_queries(affiliate_name)
      old_date = Date.current - 2
      sql = "select new.query, new.cnt, (new.cnt- ifnull(old.cnt,0)) diff from ( select query, sum(times) cnt from daily_query_stats where day>'#{old_date}' and affiliate='#{affiliate_name}' and length(query) < 30 and query REGEXP '^[[...][.-.][:alnum:][:blank:]]+$' group by query having cnt >= 10) new left outer join ( select query, sum(times) cnt from daily_query_stats where day='#{old_date}' and affiliate='#{affiliate_name}' group by query) old on old.query=new.query where (new.cnt- ifnull(old.cnt,0)) > 0 order by diff desc limit #{RESULTS_SIZE}"
      ActiveRecord::Base.connection.execute(sql).collect(&:first)
    end

    def low_ctr_queries(affiliate_name)
      oldest_day_to_consider = Date.current - 2
      low_ctr_threshold = 20
      ctr_clause = "100 * ifnull(click_count,0) / query_count"
      common_filter = "where affiliate='#{affiliate_name}' and day >= '#{oldest_day_to_consider}'"
      sql = "select dqs.query query, #{ctr_clause} ctr from "+
        "(select query, sum(times) query_count from daily_query_stats #{common_filter} "+
        "and length(query) < 30 and query REGEXP '^[[...][.-.][:alnum:][:blank:]]+$' group by query having query_count > 10) dqs "+
        "left outer join "+
        "(select query, sum(times) click_count from queries_clicks_stats #{common_filter}  group by query) qcs on ( dqs.query = qcs.query) "+
        "left outer join "+
        "(select distinct query from daily_query_noresults_stats #{common_filter}) dqnrs on (dqs.query = dqnrs.query) "+
        "where isnull(dqnrs.query) and #{ctr_clause} < #{low_ctr_threshold} order by ctr limit #{RESULTS_SIZE}"
      ActiveRecord::Base.connection.execute(sql).collect { |r| [r[0], r[1].to_i] }
    end

  end

  private

  def squish_query
    self.query.squish!
  end
end
