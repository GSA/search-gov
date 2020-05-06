# frozen_string_literal: true

class CountQuery
  include AnalyticsDSL

  def initialize(affiliate_name, type)
    @affiliate_name = affiliate_name
    @type = type
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
    end
  end

  def booleans(json)
    must_affiliate(json, affiliate_name)
    must_type(json, type)
    must_not_spider(json)
  end
end
