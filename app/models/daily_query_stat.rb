class DailyQueryStat < ActiveRecord::Base
  validates_presence_of :day
  validates_presence_of :query
  validates_presence_of :times
  validates_uniqueness_of :query, :scope => :day
  RESULTS_SIZE = 10

  def self.most_popular_terms_like(query, use_starts_with_instead_of_contains)
    contains = use_starts_with_instead_of_contains ? '' : '%'
    results = DailyQueryStat.sum(:times,
                                 :group => :query,
                                 :conditions => ["query LIKE ?", "#{contains}#{query}%"],
                                 :order => "sum_times desc")
  end

  def self.most_popular_terms(end_date, days_back, num_results = RESULTS_SIZE)
    return nil if end_date.nil?
    start_date = end_date - days_back.days + 1.day
    results = DailyQueryStat.sum(:times,
                                 :group => :query,
                                 :conditions => ['day between ? AND ?', start_date, end_date],
                                 :order => "sum_times desc")
    return nil if results.empty?
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

  def self.biggest_movers(end_date, window_size, num_results = RESULTS_SIZE)
    return nil if end_date.nil?
    start_date = end_date - window_size.days + 1.day
    results = DailyQueryStat.find_by_sql("SELECT * FROM query_accelerations qa, (SELECT sum(times) AS sum_times, query AS query FROM daily_query_stats WHERE (day between '#{start_date}' AND '#{end_date}') GROUP BY query  ) as dqs WHERE (qa.day = '#{end_date}' AND qa.window_size = #{window_size} and qa.query=dqs.query) ORDER BY score DESC LIMIT 1000").sort_by {|dqs| dqs[:sum_times].to_i}.reverse
    return nil if results.empty?
    qcs=[]
    qgcounts = {}
    grouped_queries_hash = GroupedQuery.grouped_queries_hash
    results.each do |res|
      grouped_query = grouped_queries_hash[res.query]
      if (grouped_query)
        grouped_query.query_groups.each do |query_group|
          qgcounts[query_group.name] = QueryCount.new(query_group.name, 0) if qgcounts[query_group.name].nil?
          qgcounts[query_group.name].times += res.sum_times.to_i
          qgcounts[query_group.name].children << QueryCount.new(res.query, res.sum_times)
        end
      else
        qcs << QueryCount.new(res.query, res.sum_times)
      end
    end
    qcs += qgcounts.values
    qcs.sort_by {|qc| qc.times}.reverse[0, num_results]
  end

  def self.most_recent_populated_date
    maximum(:day)
  end

  def self.collect_query_group_named(name)
    qg = QueryGroup.find_by_name(name)
    queries = qg.grouped_queries.collect {|gq| "'#{gq.query}'"}.join(',')
    results = DailyQueryStat.sum(:times, :group => :day, :conditions => "query in (#{queries})", :order => "day")
    dqs=[]
    results.each_pair { |day, times| dqs << DailyQueryStat.new(:day=> day, :times => times) }
    dqs
  end

end
