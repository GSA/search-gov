class SiteBreakdownForModuleQuery
  include AnalyticsDSL

  def initialize(module_tag)
    @module_tag = module_tag
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
      type_terms_agg(json, 'affiliate', 0)
    end
  end

  def booleans(json)
    json.must do
      json.term { json.modules @module_tag }
    end
    must_not_spider(json)
  end

end
