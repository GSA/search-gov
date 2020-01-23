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
    json.must do
      json.term { json.affiliate @affiliate_name }
    end
    must_not_spider(json)
  end


end
