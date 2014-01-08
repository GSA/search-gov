class ElasticIndexer
  def initialize(index_name)
    @rails_klass = index_name.constantize
    @elastic_klass = "Elastic#{index_name}".constantize
    @importer_klass = "Elastic#{index_name}Data".constantize
    @includes = @elastic_klass::OPTIMIZING_INCLUDES if @elastic_klass.const_defined?(:OPTIMIZING_INCLUDES)
  end

  def index_all
    @rails_klass.find_in_batches(include: @includes) do |batch|
      @elastic_klass.index(hashify_data(batch))
    end
  end

  def hashify_data(batch)
    batch.map { |instance| hashify_instance(instance) }.compact
  end

  def hashify_instance(instance)
    importer = @importer_klass.new(instance)
    builder = importer.to_builder
    builder.attributes!.symbolize_keys if builder
  end

  class << self
    def index_all(index_name)
      indexer_instance = new(index_name)
      indexer_instance.index_all
    end
  end
end
