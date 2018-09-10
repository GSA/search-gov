class DateRangeTopNQuery < TopNQuery

  def initialize(affiliate_name, start_date, end_date, agg_options = {})
    super(affiliate_name, agg_options)
    @start_date, @end_date = start_date, end_date
  end

  def booleans(json)
    must_affiliate(json, @affiliate_name)
    must_date_range(json, @start_date, @end_date)
    must_not_spider(json)
  end

end
