# frozen_string_literal: true

class TopNQuery
  include AnalyticsDSL

  def initialize(affiliate_name, type, agg_options = {})
    @affiliate_name = affiliate_name
    @type = type
    @agg_options = agg_options
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
      terms_agg(json, @agg_options)
    end
  end

  def booleans(json)
    must_affiliate(json, affiliate_name)
    must_type(json, type)
    must_not_spider(json)
  end
end
