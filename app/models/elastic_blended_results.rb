# frozen_string_literal: true

class ElasticBlendedResults < ElasticResults

  def highlight_instance(highlight, instance)
    elastic_results_klass = "Elastic#{instance.class.name}Results".constantize
    elastic_results = elastic_results_klass.new(Indexable::NO_HITS)
    elastic_results.highlight_instance(highlight, instance)
  end

  private

  def extract_results(hits)
    hits.map do |hit|
      # TODO: build a new unsaved instance of the class instead of hitting the DB for each instance,
      #  or at least group the calls so we only hit the DB once for each class.

      rails_model_klass = rails_model_for_index(hit['_index'])
      next unless rails_model_klass

      instance = rails_model_klass.find_by_id(hit['_id'])
      highlight(hit['highlight'], instance)
    end.compact
  end

  # OpenSearch responses no longer include a per-hit `_type`, so the source
  # model is resolved from the index name instead.
  def rails_model_for_index(index)
    ElasticBlended::INDEXES.find do |model_name|
      index.start_with?("Elastic#{model_name}".constantize.base_index_name)
    end&.constantize
  end

end