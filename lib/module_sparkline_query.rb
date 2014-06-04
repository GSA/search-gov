class ModuleSparklineQuery

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
      json.child! { json.term { json.affiliate @affiliate_name } }
      json.child! { since(json) }
      json.child! { json.exists { json.field 'modules' } }
    end
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
        histogram_type_agg(json)
      end
    end
  end

  def histogram_type_agg(json)
    json.aggs do
      json.histogram do
        json.date_histogram do
          json.field '@timestamp'
          json.interval 'day'
          json.format 'yyyy-MM-dd'
          json.min_doc_count 0
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

  private
  def since(json)
    json.range do
      json.set! "@timestamp" do
        json.gte 'now-60d/d'
      end
    end
  end


end
