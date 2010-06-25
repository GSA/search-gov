class DailyQueryStat < ActiveRecord::Base
  validates_presence_of :day, :query, :times, :affiliate, :locale
  validates_uniqueness_of :query, :scope => [:day, :affiliate, :locale]
  RESULTS_SIZE = 10
  INSUFFICIENT_DATA = "Not enough historic data to compute most popular"
  DEFAULT_AFFILIATE_NAME = "usasearch.gov"

  def self.most_popular_terms_like(query, use_starts_with_instead_of_contains, affiliate_name = DEFAULT_AFFILIATE_NAME, locale = I18n.default_locale.to_s)
    contains = use_starts_with_instead_of_contains ? '' : '%'
    DailyQueryStat.sum(:times,
                       :group => :query,
                       :conditions => ["query LIKE ? AND affiliate = ? AND locale = ?", "#{contains}#{query}%", affiliate_name, locale],
                       :order => "sum_times desc")
  end

  def self.reversed_backfilled_series_since_2009_for(query, up_to_day = Date.yesterday.to_date)
    timeline = Timeline.new(query)
    ary = []
    timeline.dates.each_with_index do |day, idx|
      ary << timeline.series[idx].y if day <= up_to_day
    end
    ary.reverse
  end

  def self.most_popular_terms(end_date, days_back, num_results = RESULTS_SIZE, affiliate_name = DEFAULT_AFFILIATE_NAME, locale = I18n.default_locale.to_s)
    return INSUFFICIENT_DATA if end_date.nil?
    start_date = end_date - days_back.days + 1.day
    results = DailyQueryStat.sum(:times,
                                 :group => :query,
                                 :conditions => ['day between ? AND ? AND affiliate = ? AND locale = ?', start_date, end_date, affiliate_name, locale],
                                 :having => "sum_times > #{ affiliate_name == DEFAULT_AFFILIATE_NAME ? "3" : "0"}",
                                 :order => "sum_times desc")
    return INSUFFICIENT_DATA if results.empty?
    qcs=[]
    qgcounts = {}
    grouped_queries_hash = GroupedQuery.grouped_queries_hash
    results.each_pair do |query, times|
      grouped_query = grouped_queries_hash[query]
      if (grouped_query)
        grouped_query.query_groups.each do |query_group|
          qgcounts[query_group.name] = QueryCount.new(query_group.name, 0) if qgcounts[query_group.name].nil?
          qgcounts[query_group.name].times += times.to_i
          qgcounts[query_group.name].children << QueryCount.new(query, times)
        end
      else
        qcs << QueryCount.new(query, times)
      end
    end
    qcs += qgcounts.values
    qcs.sort_by {|qc| qc.times}.reverse[0, num_results]
  end

  def self.most_recent_populated_date(affiliate_name = DEFAULT_AFFILIATE_NAME, locale = I18n.default_locale.to_s)
    maximum(:day, :conditions => ['affiliate = ? AND locale = ?', affiliate_name, locale])
  end

  def self.collect_query_group_named(name)
    qg = QueryGroup.find_by_name(name)
    queries = qg.grouped_queries.collect {|gq| "'#{gq.query}'"}.join(',')
    results = DailyQueryStat.sum(:times, :group => :day, :conditions => "query in (#{queries}) AND affiliate = '#{DEFAULT_AFFILIATE_NAME}' AND locale = '#{I18n.default_locale.to_s}'", :order => "day")
    dqs=[]
    results.each_pair { |day, times| dqs << DailyQueryStat.new(:day=> day, :times => times, :affiliate => DEFAULT_AFFILIATE_NAME, :locale => I18n.default_locale.to_s) }
    dqs
  end

end
