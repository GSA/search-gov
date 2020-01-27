# frozen_string_literal: true

class SiteBreakdownForModuleQuery
  include AnalyticsDSL

  def initialize(module_tag)
    @module_tag = module_tag
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
      type_terms_agg(json, 'params.affiliate', 10_000)
    end
  end

  def booleans(json)
    json.filter do
      json.term { json.modules @module_tag }
    end
    must_not_spider(json)
  end
end
