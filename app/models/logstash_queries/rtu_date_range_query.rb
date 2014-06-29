class RtuDateRangeQuery
  include AnalyticsDSL

  def initialize(affiliate_name)
    @affiliate_name = affiliate_name
  end

  def body
    Jbuilder.encode do |json|
      filter(json) do |json|
        json.bool do
          booleans(json)
        end
      end
      stats(json, "@timestamp")
    end
  end

  def booleans(json)
    json.must do
      json.term { json.affiliate @affiliate_name }
    end
    must_not_spider(json)
  end

end
