class DateRangeTopNFieldQuery < DateRangeTopNQuery
  attr_reader :filter_field, :filter_value

  def initialize(affiliate_name, type, start_date, end_date, filter_field, filter_value, agg_options = {})
    super(affiliate_name, type, start_date, end_date, agg_options)
    @filter_field = filter_field
    @filter_value = filter_value
  end

  def booleans(json)
    must_affiliate(json, affiliate_name) if affiliate_name
    must_type(json, type)

    json.filter do
      json.child! { json.term { json.set! filter_field, filter_value } }
    end

    must_date_range(json, start_date, end_date)
  end
end
