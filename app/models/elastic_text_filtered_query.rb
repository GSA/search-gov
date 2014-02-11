class ElasticTextFilteredQuery < ElasticQuery

  def filtered_query(json)
    json.query do
      json.filtered do
        filtered_query_query(json)
        filtered_query_filter(json)
      end
    end
  end

  def filtered_query_query(json)
    json.query do
      query_string(json, highlighted_fields, @q, query_string_options)
    end if @q.present?
  end

  def query_string(json, fields, query, options = {})
    json.query_string do
      json.fields fields
      json.query query
      options.each do |option, value|
        json.set! option, value
      end
    end
  end

  def query_string_options
    { analyzer: @text_analyzer, default_operator: 'AND' }
  end

end