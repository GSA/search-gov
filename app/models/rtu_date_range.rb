class RtuDateRange
  def initialize(affiliate_name, type)
    @affiliate_name = affiliate_name
    @type = type
  end

  def available_dates_range
    rtu_date_range_query = RtuDateRangeQuery.new(@affiliate_name)
    result = search(rtu_date_range_query.body)
    result.present? ? extract_date_range(result) : Date.current..Date.current
  end

  private

  def search(query_body)
    ES::client_reader.search(index: "logstash-*", type: @type, body: query_body, size: 0) rescue nil
  end

  def extract_date_range(result)
    stats = result["facets"]["stats"]
    min, max = normalize(stats["min"]), normalize(stats["max"])
    min..max
  end

  def normalize(unixtime)
    unixtime =~ /Infinity/ ? Date.current : DateTime.strptime(unixtime.to_s, '%Q').to_date
  end
end