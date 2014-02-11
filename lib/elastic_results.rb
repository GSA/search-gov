class ElasticResults
  attr_reader :total, :offset, :results, :facets

  def initialize(hits, facets)
    @total = hits['total']
    @offset = hits['offset']
    @results = extract_results(hits['hits'])
    @facets = extract_facets(facets) if facets
  end

  private

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
      highlight_instance(highlight, instance)
    end
    instance
  end

  def extract_facets(facets)
    facets.collect do |field, data|
      Hashie::Rash.new(name: field, rows: extract_facet_rows(data['terms']))
    end
  end

  def extract_facet_rows(rows)
    rows.map { |term_hash| { value: term_hash['term'] } }
  end

end
