# frozen_string_literal: true

class QueryBreakdownForSiteModuleQuery
  include AnalyticsDSL

  def initialize(module_tag, site_name)
    @module_tag = module_tag
    @site_name = site_name
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
      type_terms_agg(json, 'params.query.raw', 1000)
    end
  end

  def booleans(json)
    json.filter do
      json.child! { json.term { json.modules @module_tag } }
      json.child! { json.term { json.set! 'params.affiliate', @site_name } }
    end
    must_not_spider(json)
  end
end
