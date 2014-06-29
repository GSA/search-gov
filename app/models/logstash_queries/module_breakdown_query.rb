class ModuleBreakdownQuery
  include AnalyticsDSL

  def initialize(affiliate_name = nil)
    @affiliate_name = affiliate_name
  end

  def body
    Jbuilder.encode do |json|
      filter(json) do |json|
        json.bool do
          booleans(json)
        end
      end
      modules_type_terms_agg(json)
    end
  end

  def booleans(json)
    json.must do
      json.term { json.affiliate @affiliate_name }
    end if @affiliate_name.present?
    must_not_spider(json)
  end

  def modules_type_terms_agg(json)
    json.aggs do
      json.agg do
        json.terms do
          json.field 'modules'
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
