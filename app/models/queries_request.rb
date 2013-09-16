class QueriesRequest
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
    @available_dates= DailyQueryStat.available_dates_range(site.name)
    @end_date = end_date.nil? ? DailyQueryStat.most_recent_populated_date(site.name) : end_date.to_date
    @start_date = start_date.nil? ? (@end_date and @end_date.beginning_of_month) : start_date.to_date
    @top_queries = compute_top_queries
  end

  private

  def compute_top_queries
    if @query.blank?
      most_popular_terms = DailyQueryStat.most_popular_terms(@site.name, @start_date, @end_date)
      return [] if most_popular_terms.instance_of? String
      most_popular_terms
    elsif @start_date.present? and @end_date.present?
      DailyQueryStat.query_counts_for_terms_like(@query, @site.name, @start_date, @end_date).collect { |hash| QueryCount.new(hash.first, hash.last) }
    end
  end

end
