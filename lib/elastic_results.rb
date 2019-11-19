# frozen_string_literal: true

class ElasticResults
  attr_reader :total, :offset, :results, :aggregations, :suggestion

  def initialize(result)
    @total = result['hits']['total']
    @offset = result['hits']['offset']
    @results = extract_results(result['hits']['hits'])
    @aggregations = extract_aggregations(result['aggregations']) if result['aggregations']
    @suggestion = extract_suggestion(result['suggest']['suggestion']) if result['suggest']
  end

  def override_suggestion(suggestion)
    @suggestion = suggestion
  end

  private

  def extract_suggestion(suggestions)
    Hashie::Mash::Rash.new(suggestions.first['options'].first)
  end

  def extract_results(hits)
    rails_model_klass = self.class.name.match(/\AElastic(.*)Results\z/)[1].constantize
    elastic_model_klass = "Elastic#{rails_model_klass}".constantize
    ids = hits.collect { |hit| hit['_id'] }
    optimizing_includes = elastic_model_klass.const_defined?(:OPTIMIZING_INCLUDES) ? elastic_model_klass::OPTIMIZING_INCLUDES : nil
    instances = rails_model_klass.where(id: ids).includes(optimizing_includes)
    instance_hash = Hash[instances.map { |instance| [instance.id, instance] }]
    hits.map { |hit| highlight(hit['highlight'], instance_hash[hit['_id'].to_i]) }.compact
  end

  def highlight(highlight, instance)
    if highlight.present? and instance.present?
      highlight.transform_keys! { |key| key.remove(/\..*/) }
      highlight_instance(highlight, instance)
    end
    instance
  end

  def extract_aggregations(aggregations)
    aggregations.collect do |field, data|
      Hashie::Mash::Rash.new(name: field, rows: extract_aggregation_rows(data['buckets']))
    end
  end

  def extract_aggregation_rows(rows)
    rows.map { |term_hash| { value: term_hash['key'] } }
  end

end
