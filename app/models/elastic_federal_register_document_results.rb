# frozen_string_literal: true

class ElasticFederalRegisterDocumentResults < ElasticResults

  def initialize(result)
    @offset = result['hits']['offset']
    @aggregations = extract_aggregations(result['aggregations']) if result['aggregations']
    hits = @aggregations.map { |bucket| bucket.rows.map(&:value) }.flatten
    @results = extract_results(hits.first(3))
    @total = hits.present? ? hits.count : 0
  end

  def highlight_instance(highlight, instance)
    instance.title = highlight['title'].first if highlight['title']
    instance
  end

  def extract_aggregation_rows(rows)
    rows.map { |term_hash| { value: term_hash['top_tag_hits']['hits']['hits'] } }
  end
end
