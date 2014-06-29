class TopNQuery
  include AnalyticsDSL

  def initialize(affiliate_name, agg_options = {})
    @affiliate_name = affiliate_name
    @agg_options = agg_options
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
      terms_agg(json, @agg_options)
    end
  end

  def booleans(json)
    json.must do
      json.term { json.affiliate @affiliate_name }
    end
    must_not_spider(json)
  end

end
