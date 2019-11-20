# frozen_string_literal: true

class DrilldownQuery
  include AnalyticsDSL

  def initialize(affiliate_name, start_date, end_date, field, value)
    @affiliate_name, @start_date, @end_date, @field, @value = affiliate_name, start_date, end_date, field, value
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
      json.child! { json.term { json.affiliate @affiliate_name } }
    end
    must_not_spider(json)
  end

end
