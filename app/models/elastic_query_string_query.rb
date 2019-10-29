module ElasticQueryStringQuery
  def filtered_query_query(json)
    json.query do
      json.bool do
        json.must do
          json.child! { query_string(json, highlighted_fields, @q, query_string_options) }
        end
      end
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

end