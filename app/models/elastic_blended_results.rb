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

      rails_model_klass = hit['_type'].camelize.sub('Elastic','').constantize
      instance = rails_model_klass.find_by_id(hit['_id'])
      highlight(hit['highlight'], instance)
    end.compact
  end

end