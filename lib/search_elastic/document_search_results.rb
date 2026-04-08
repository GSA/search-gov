# frozen_string_literal: true

class SearchElastic::DocumentSearchResults
  attr_reader :total, :offset, :results, :suggestion, :aggregations

  def initialize(result, offset = 0)
    @total = result['hits']['total']
    @offset = offset
    @results = extract_hits(result['hits']['hits'])
    @suggestion = extract_suggestion(result['suggest'])
    @aggregations = extract_aggregations(result['aggregations'])
  end

  def override_suggestion(suggestion)
    @suggestion = suggestion
  end

  private

  def extract_suggestion(suggest)
    return unless suggest && total.zero?

    suggest['suggestion'].first['options'].first.except('score')
  rescue NoMethodError
    nil
  end

  def extract_hits(hits)
    hits.map do |hit|
      highlight = hit['highlight']
      source =  deserialized(hit)
      if highlight.present?
        source['title'] = highlight["title_#{source['language']}"].first if highlight["title_#{source['language']}"]
        %w[description content].each do |optional_field|
          language_field = "#{optional_field}_#{source['language']}"
          source[optional_field] = highlight[language_field].join('...') if highlight[language_field]
        end
      end

      %w[created_at created changed updated_at updated].each do |date|
        source[date] = Time.parse(source[date]).utc.to_s if source[date].present?
      end
      source
    end
  end

  def extract_aggregations(aggregations)
    return unless aggregations

    aggregations.filter_map do |field, data|
      if data['buckets'].present? && !data['buckets'].all? { |b| b['doc_count'].zero? }
        { "#{field}": extract_aggregation_rows(data['buckets']) }
      end
    end
  end

  def extract_aggregation_rows(rows)
    rows.filter_map do |term_hash|
      next if term_hash['doc_count'].zero?

      {
        agg_key: term_hash['key'],
        doc_count: term_hash['doc_count'],
        to: term_hash['to'] || nil,
        from: term_hash['from'] || nil,
        to_as_string: term_hash['to_as_string'] || nil,
        from_as_string: term_hash['from_as_string'] || nil
      }.compact
    end
  end

  def deserialized(hit)
    Serde.deserialize_hash(hit['_source'], hit['_source']['language'])
  end
end
