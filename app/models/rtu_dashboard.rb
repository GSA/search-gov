class RtuDashboard < Dashboard

  def top_queries
    query_body = top_n_query('raw')
    buckets = top_n(query_body, 'search')
    buckets.collect { |hash| QueryCount.new(hash["key"], hash["doc_count"]) } if buckets
  end

  def top_urls
    query_body = top_n_query('params.url')
    buckets = top_n(query_body, 'click')
    Hash[buckets.collect { |hash| [hash["key"], hash["doc_count"]] }] if buckets
  end

  private

  def top_n(query_body, type)
    result = ES::client_reader.search(index: "logstash-#{@day.strftime("%Y.%m.%d")}", type: type, body: query_body, size: 0)
    result["aggregations"]["agg"]["buckets"]
  rescue Exception => e
    nil
  end

  def top_n_query(field)
    Jbuilder.encode do |json|
      site_filter(json)
      terms_agg(json, field)
    end
  end

  def site_filter(json)
    json.query do
      json.filtered do
        json.filter do
          json.bool do
            json.must do
              json.term { json.affiliate @site.name }
            end
            json.must_not do
              json.term { json.set! "useragent.device", "Spider" }
            end
          end
        end
      end
    end
  end

  def terms_agg(json, field, size = 10)
    json.aggs do
      json.agg do
        json.terms do
          json.field field
          json.size size
        end
      end
    end
  end

end
