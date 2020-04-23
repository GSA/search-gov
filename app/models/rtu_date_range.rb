# frozen_string_literal: true

class RtuDateRange
  attr_reader :affiliate_name, :type

  def initialize(affiliate_name, type)
    @affiliate_name = affiliate_name
    @type = type
  end

  def available_dates_range
    rtu_date_range_query = RtuDateRangeQuery.new(affiliate_name, type)
    result = search(rtu_date_range_query.body)
    result.present? ? extract_date_range(result) : Date.current..Date.current
  end

  def default_start
    default_end.beginning_of_month
  end

  def default_end
    available_dates_range.end
  end

  private

  def search(query_body)
    ES::ELK.client_reader.search(
      index: 'logstash-*',
      body: query_body,
      size: 0
    )
  rescue StandardError
    nil
  end

  def extract_date_range(result)
    aggregations = result['aggregations']
    return Date.current..Date.current if aggregations.nil?

    stats = aggregations['stats']
    min = normalize(stats['min'])
    max = normalize(stats['max'])
    min..max
  end

  def normalize(unixtime)
    unixtime.blank? ? Date.current : Time.strptime(unixtime.to_s, '%Q').to_date
  end
end
