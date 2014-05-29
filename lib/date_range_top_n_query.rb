class DateRangeTopNQuery < TopNQuery
  include DateRangeFilter

  def initialize(affiliate_name, start_date, end_date, agg_options = {})
    super(affiliate_name, agg_options)
    @start_date, @end_date = start_date, end_date
  end

  def booleans(json)
    json.must do
      json.child! { json.term { json.affiliate @affiliate_name } }
      json.child! { date_range(json, '@timestamp', @start_date, @end_date) }
    end
  end

end