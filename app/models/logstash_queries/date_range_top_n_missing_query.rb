# frozen_string_literal: true

class DateRangeTopNMissingQuery < TopNMissingQuery
  def initialize(affiliate_name, start_date, end_date, agg_options = {})
    super(affiliate_name, agg_options)
    @start_date, @end_date = start_date, end_date
  end

  def additional_musts(json)
    json.child! { date_range(json, @start_date, @end_date) }
  end
end
