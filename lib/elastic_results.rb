class ElasticResults
  attr_reader :total, :offset, :results

  def initialize(hits)
    @total = hits['total']
    @offset = hits['offset']
    @results = extract_results(hits['hits'])
  end

  private

  def extract_results(hits)
    rails_model_klass = self.class.name.match(/\AElastic(.*)Results\z/)[1].constantize
    elastic_model_klass = "Elastic#{rails_model_klass}".constantize
    ids = hits.collect { |hit| hit['_id'] }
    optimizing_includes = elastic_model_klass.const_defined?(:OPTIMIZING_INCLUDES) ? elastic_model_klass::OPTIMIZING_INCLUDES : nil
    instances = rails_model_klass.where(id: ids).includes(optimizing_includes)
    instance_hash = Hash[instances.map { |instance| [instance.id, instance] }]
    hits.map { |hit| highlight_instance(hit['highlight'], instance_hash[hit['_id'].to_i]) }.compact
  end

end
