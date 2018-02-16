class ElasticIndexer
  DEFAULT_BATCH_SIZE = 100

  def initialize(index_name)
    @rails_klass = index_name.constantize
    @elastic_klass = "Elastic#{index_name}".constantize
    @importer_klass = "Elastic#{index_name}Data".constantize
    @includes = @elastic_klass::OPTIMIZING_INCLUDES if @elastic_klass.const_defined?(:OPTIMIZING_INCLUDES)
  end

  def index_all
    @rails_klass.includes(@includes).find_in_batches(batch_size: DEFAULT_BATCH_SIZE) do |batch|
      index_batch(batch)
    end
  end

  def index_batch(batch)
    data = hashify_data(batch)
    @elastic_klass.index(data) if data.present?
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
