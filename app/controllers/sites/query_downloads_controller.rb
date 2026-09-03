# frozen_string_literal: true

class Sites::QueryDownloadsController < Sites::SetupSiteController
  include CsvResponsive
  MAX_RESULTS = 50_000

  def show
    @end_date = params['end_date'].to_date
    @start_date = params['start_date'].to_date
    filename = [@site.name, @start_date, @end_date].join('_')
    header = [
      'Search Term',
      'Queries',
      'Clicks',
      'CTR'
    ]
    csv_response(filename, header, top_queries)
  end

  private

  def top_queries
    report_array = query_count_array.map do |query_term, query_count|
      click_count = click_count_hash[query_term] || 0

      [
        query_term,
        query_count,
        click_count,
        ctr(click_count, query_count)
      ]
    end

    report_array.sort_by { |a| -a[1] }
  end

  def ctr(click_count, query_count)
    return '--' if click_count.zero? || query_count.zero?

    sprintf('%.1f%%', click_count.to_f * 100 / query_count)
  end

  def date_range_top_n_query(type)
    DateRangeTopNQuery.new(
      @site.name,
      type,
      @start_date,
      @end_date,
      field: 'params.query.raw',
      size: MAX_RESULTS
    )
  end

  def query_count_array
    @query_count_array ||= RtuTopQueries.new(date_range_top_n_query('search').body).top_n
  end

  def click_count_hash
    @click_count_hash ||= Hash[RtuTopClicks.new(date_range_top_n_query('click').body).top_n]
  end
end
