# frozen_string_literal: true

class DrilldownQuery
  include AnalyticsDSL

  def initialize(affiliate_name, start_date, end_date, field, value, type)
    @affiliate_name = affiliate_name
    @start_date = start_date
    @end_date = end_date
    @field = field
    @value = value
    @type = type
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
    end
  end

  def booleans(json)
    json.filter do
      json.child! { date_range(json, @start_date, @end_date) }
      json.child! { json.term { json.set! @field, @value } }
    end
    must_affiliate(json, @affiliate_name)
    must_type(json, type)
    must_not_spider(json)
  end
end
