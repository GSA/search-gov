class OverallSparklineQuery < ModuleSparklineQuery

  def terms_agg(json)
    histogram_type_agg(json)
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

end
