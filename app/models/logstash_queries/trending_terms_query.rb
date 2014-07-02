class TrendingTermsQuery
  include AnalyticsDSL

  def initialize(affiliate_name, foreground_time = '3h', min_foreground_doc_count = 15)
    @affiliate_name = affiliate_name
    @foreground_time = foreground_time
    @min_foreground_doc_count = min_foreground_doc_count
  end

  def body
    Jbuilder.encode do |json|
      json.query do
        json.filtered do
          json.filter do
            booleans(json)
          end
          json.query do
            since(json, "now-#{@foreground_time}/h")
          end
        end
      end
      significant_terms_agg(json)
    end
  end

  def significant_terms_agg(json)
    json.aggs do
      json.agg do
        json.significant_terms do
          json.min_doc_count @min_foreground_doc_count
          json.field "params.query.raw"
          json.background_filter do
            booleans(json)
          end
        end
        json.aggs do
          json.clientip_count do
            json.cardinality do
              json.field "clientip"
            end
          end
        end
      end
    end
  end

  def booleans(json)
    json.bool do
      json.must do
        json.child! { json.term { json.affiliate @affiliate_name } }
        json.child! { json.term { json.type "search" } }
      end
      json.must_not do
        json.child! { json.term { json.set! "useragent.device", "Spider" } }
        json.child! { json.term { json.raw "" } }
        json.child! { json.exists { json.field "params.page" } }
      end
    end
  end

end
