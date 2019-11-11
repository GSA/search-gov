# frozen_string_literal: true

class CountQuery
  include AnalyticsDSL

  def initialize(affiliate_name)
    @affiliate_name = affiliate_name
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
    end
  end

  def booleans(json)
    json.filter do
      json.term { json.set! 'params.affiliate', @affiliate_name }
    end
    must_not_spider(json)
  end
end
