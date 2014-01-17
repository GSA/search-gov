class ElasticMigration
  def initialize(index_name)
    @index_name = index_name
    @elastic_klass = "Elastic#{index_name}".constantize
  end

  def migrate
    @elastic_klass.migrate_writer
    ElasticIndexer.index_all(@index_name)
    @elastic_klass.migrate_reader
  end

  class << self
    def migrate(index_name)
      migration_instance = new(index_name)
      migration_instance.migrate
    end
  end
end