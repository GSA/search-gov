class ElasticMigrateReader
  @queue = :high

  class << self
    def perform(index_name)
      "Elastic#{index_name}".constantize.migrate_reader
    end
  end

end