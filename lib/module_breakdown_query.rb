class ModuleBreakdownQuery

  def initialize(affiliate_name = nil)
    @affiliate_name = affiliate_name
  end

  def body
    Jbuilder.encode do |json|
      filter(json)
      terms_agg(json)
    end
  end

  def filter(json)
    json.query do
      json.filtered do
        json.filter do
          json.bool do
            booleans(json)
          end
        end
      end
    end
  end

  def booleans(json)
    json.must do
      json.term { json.affiliate @affiliate_name }
    end if @affiliate_name.present?
    json.must_not do
      json.term { json.set! "useragent.device", "Spider" }
    end
  end

  def terms_agg(json)
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
