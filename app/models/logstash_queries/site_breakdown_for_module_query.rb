class SiteBreakdownForModuleQuery
  include AnalyticsDSL

  def initialize(module_tag)
    @module_tag = module_tag
  end

  def body
    Jbuilder.encode do |json|
      filter_booleans(json)
      site_type_terms_agg(json)
    end
  end

  def booleans(json)
    json.must do
      json.term { json.modules @module_tag }
    end
    must_not_spider(json)
  end

  def site_type_terms_agg(json)
    json.aggs do
      json.agg do
        json.terms do
          json.field 'affiliate'
          json.size 0
        end
        json.aggs do
          json.type do
            json.terms do
              json.field 'type'
            end
          end
        end
      end
    end
  end

end
