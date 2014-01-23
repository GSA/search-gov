class ElasticResqueIndexer < ElasticIndexer
  @queue = :high

  def initialize(index_name, start_id, end_id)
    super(index_name)
    @start_id, @end_id = start_id, end_id
  end

  def index_all
    batch = @rails_klass.where(id: @start_id..@end_id).includes(@includes)
    index_batch(batch)
  end

  class << self
    def index_all(index_name)
      rails_klass = index_name.constantize
      rails_klass.select(rails_klass.primary_key.to_sym).find_in_batches(batch_size: ElasticIndexer::DEFAULT_BATCH_SIZE) do |records|
        Resque.enqueue(ElasticResqueIndexer, index_name, records.first.id, records.last.id)
      end
    end

    def perform(index_name, start_id, end_id)
      indexer_instance = new(index_name, start_id, end_id)
      indexer_instance.index_all
    end
  end

end