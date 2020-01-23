class ModuleBreakdownQuery
  include AnalyticsDSL

  def initialize(affiliate_name = nil)
    @affiliate_name = affiliate_name
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
      type_terms_agg(json, 'modules', 0)
    end
  end

  def booleans(json)
    json.must do
      json.term { json.affiliate @affiliate_name }
    end if @affiliate_name.present?
    must_not_spider(json)
  end

end
