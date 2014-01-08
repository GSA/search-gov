class ElasticResqueMigration < ElasticMigration

  def migrate
    @elastic_klass.migrate_writer
    ElasticResqueIndexer.index_all(@index_name)
    Resque.enqueue(ElasticMigrateReader, @index_name)
  end

end