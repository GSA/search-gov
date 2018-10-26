class DateRangeTopNFieldQuery < DateRangeTopNQuery
  attr_reader :filters

  def initialize(affiliate_name, start_date, end_date, filter_field, filter_value, agg_options = {})
    super(affiliate_name, start_date, end_date, agg_options)
    @filters = { 'affiliate' => @affiliate_name, filter_field => filter_value }.compact
  end

  def booleans(json)
    filters.each do |field, value|
      json.must do
        json.child! { json.term { json.set! field, value } }
      end
    end

    json.must do
      json.child! { date_range(json, @start_date, @end_date) }
    end
  end
end
