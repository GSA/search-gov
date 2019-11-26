# frozen_string_literal: true

class RtuDateRangeQuery
  include AnalyticsDSL

  def initialize(affiliate_name)
    @affiliate_name = affiliate_name
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
      stats(json, "@timestamp")
    end
  end

  def booleans(json)
    must_affiliate(json, @affiliate_name)
    must_not_spider(json)
  end
end
