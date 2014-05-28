class RtuDateRangeQuery
  include AffiliateMinusSpiderFilter

  def initialize(affiliate_name)
    @affiliate_name = affiliate_name
  end

  def body
    Jbuilder.encode do |json|
      filter(json)
      stats(json)
    end
  end

  def stats(json)
    json.facets do
      json.stats do
        json.statistical do
          json.field "@timestamp"
        end
      end
    end
  end

end
