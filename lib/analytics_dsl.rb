module AnalyticsDSL
  def filter(json)
    json.query do
      json.filtered do
        json.filter do
          yield json
        end
      end
    end
  end

  def filter_booleans(json)
    filter(json) do |json|
      json.bool do
        booleans(json)
      end
    end
  end

  def terms_agg(json, agg_options)
    json.aggs do
      json.agg do
        json.terms do
          agg_options.each do |option, value|
            json.set! option, value
          end
        end
        yield json if block_given?
      end
    end
  end

  def date_range(json, start_date, end_date)
    json.range do
      json.set! "@timestamp" do
        json.gte start_date
        json.lte end_date if end_date.present?
      end
    end
  end

  def since(json, since_when)
    date_range(json, since_when, nil)
  end

  def must_not_spider(json)
    json.must_not do
      json.term { json.set! "useragent.device", "Spider" }
    end
  end

  def stats(json, field)
    json.facets do
      json.stats do
        json.statistical do
          json.field field
        end
      end
    end
  end

  def type_terms_agg(json, field_name, size)
    terms_agg(json, field: field_name, size: size) do
      json.aggs do
        json.type do
          json.terms do
            json.field 'type'
          end
        end
      end
    end
  end

  def must_affiliate(json, site_name)
    json.must do
      json.child! { json.term { json.affiliate site_name } }
    end
  end

  def must_date_range(json, start_date, end_date)
    json.must do
      json.child! { date_range(json, start_date, end_date) }
    end
  end
end
