class DateRangeTopNQuery < TopNQuery
  include DateRangeFilter

  def initialize(affiliate_name, start_date, end_date, agg_options = {})
    super(affiliate_name, agg_options)
    @start_date, @end_date = start_date, end_date
  end

  def booleans(json)
    must_affiliate_date_range(json, @affiliate_name, '@timestamp', @start_date, @end_date)
  end

end