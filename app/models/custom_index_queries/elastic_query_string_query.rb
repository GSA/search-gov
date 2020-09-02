# frozen_string_literal: true

module ElasticQueryStringQuery
  def filtered_query_query(json)
    return if @q.blank?

    json.must do
      json.child! { query_string(json, highlighted_fields, @q, query_string_options) }
    end
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
