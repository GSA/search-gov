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
    must_type(json, %w[search click])
    json.filter do
      json.child! { json.term { json.modules @module_tag } }
    end
    must_affiliate(json, @site_name)
    must_not_spider(json)
  end
end
