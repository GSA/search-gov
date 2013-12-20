class QueriesRequest
  MAX_RESULTS = 1000
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion

  attr_reader :start_date, :end_date, :top_queries, :available_dates, :query

  attribute :site, Affiliate
  attribute :start_date, String
  attribute :end_date, String
  attribute :query, String

  def persisted?
    false
  end

  def save
    @available_dates = DailyQueryStat.available_dates_range(site.name)
    @end_date = end_date.nil? ? DailyQueryStat.most_recent_populated_date(site.name) : end_date.to_date
    @start_date = start_date.nil? ? (@end_date and @end_date.beginning_of_month) : start_date.to_date
    @top_queries = compute_top_query_stats
  end

  private

  def compute_top_query_stats
    ids_clause = @query.present? ? matching_ids : nil
    fields = "q.query query, q.cnt queries, ifnull(c.cnt,0) clicks, 100.0*ifnull(c.cnt,0)/q.cnt ctr"
    sql = "select #{fields} from (#{table_subquery('daily_query_stats')} #{ids_clause} #{group_count_limit(MAX_RESULTS)}) q LEFT OUTER JOIN (#{table_subquery('queries_clicks_stats')} #{group_count_limit(5*MAX_RESULTS)}) c on q.query = c.query order by q.cnt desc"
    ActiveRecord::Base.connection.execute(sql).map { |tuple| QueryClickCount.new(*tuple) }
  end

  def matching_ids
    ids = DailyQueryStat.search_for(@query, @site.name, @start_date, @end_date, MAX_RESULTS)
    ids = [-1] unless ids.present?
    "and id in (#{ids.join(',')})"
  end

  def table_subquery(tablename)
    "select query, sum(times) cnt from #{tablename} where affiliate='#{@site.name}' and day between '#{@start_date}' and '#{@end_date}'"
  end

  def group_count_limit(limit)
    "group by query order by cnt desc limit #{limit}"
  end
end
