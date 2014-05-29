class DateRangeTopNFieldQuery < DateRangeTopNQuery
  def initialize(affiliate_name, start_date, end_date, filter_field, filter_value, agg_options = {})
    super(affiliate_name, start_date, end_date, agg_options)
    @filter_field, @filter_value = filter_field, filter_value
  end

  def booleans(json)
    json.must do
      json.child! { json.term { json.affiliate @affiliate_name } }
      json.child! { json.term { json.set! @filter_field, @filter_value } }
      json.child! { date_range(json) }
    end
  end

end