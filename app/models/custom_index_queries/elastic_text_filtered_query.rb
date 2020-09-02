# frozen_string_literal: true

class ElasticTextFilteredQuery < ElasticQuery
  def query(json)
    filtered_query(json)
  end

  def filtered_query(json)
    json.query do
      json.bool do
        filtered_query_query(json)
        filtered_query_filter(json)
      end
    end
  end

  def filtered_query_query(json)
    return if @q.blank?

    json.must do
      json.child! { query_string(json, highlighted_fields, @q, query_string_options) }
      json.child! { multi_match(json, highlighted_fields, @q, multi_match_options) }
    end
  end

  def query_string(json, fields, query, options = {})
    json.simple_query_string do
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

  def multi_match_options
    { analyzer: @text_analyzer }
  end
end
