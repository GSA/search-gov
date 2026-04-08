namespace :usasearch do
  namespace :elasticsearch do
    desc 'Index all ActiveRecord-based Rails data for given plus-separated indexes'
    task :index_all, [:index_names] => :environment do |t, args|
      index_all(args.index_names, ElasticIndexer)
    end

    desc 'Use Resque to parallelize indexing of all ActiveRecord-based Rails data for given plus-separated indexes'
    task :resque_index_all, [:index_names] => :environment do |t, args|
      index_all(args.index_names, ElasticResqueIndexer)
    end

    desc 'Migrate and index an index'
    task :migrate, [:index_name] => :environment do |t, args|
      ElasticMigration.migrate(args.index_name)
    end

    desc 'Use Resque to migrate and index an index in parallel'
    task :resque_migrate, [:index_name] => :environment do |t, args|
      ElasticResqueMigration.migrate(args.index_name)
    end

    desc 'Use Resque to migrate and index all indexes in parallel'
    task :resque_migrate_all => :environment do
      Dir[Rails.root.join('app/models/elastic_*.rb').to_s].collect do |filename|
        File.basename(filename, '.rb').camelize.constantize
      end.select do |klass|
        klass.kind_of?(Indexable) and klass != ElasticBlended
      end.each do |klass|
        ElasticResqueMigration.migrate(klass.to_s.sub('Elastic', ''))
      end
    end

    desc 'Recreate an index'
    task :recreate_index, [:index_name] => :environment do |t, args|
      "Elastic#{args.index_name}".constantize.recreate_index
    end

    desc 'Ensure all indexes are created'
    task create_indexes: :environment do
      Dir[Rails.root.join('app/models/elastic_*.rb').to_s].each do |filename|
        klass = File.basename(filename, '.rb').camelize.constantize
        # Skip classes that use OpenSearch (they are created by opensearch:create_all_indexes)
        next if klass.respond_to?(:use_opensearch?) && klass.use_opensearch?

        klass.create_index if klass.kind_of?(Indexable) && klass != ElasticBlended && !klass.index_exists?
      end
    end
  end

  def index_all(index_names, indexer_klass)
    index_names.split('+').each do |index_name|
      indexer_klass.index_all(index_name.squish)
    end
  end

end
