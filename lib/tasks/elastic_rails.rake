namespace :usasearch do
  namespace :elasticsearch do
    desc 'Reindex Rails data for given comma separated indexes'
    task :reindex, [:index_names] => :environment do |t, args|
      args.index_names.split(',').each do |index_name|
        rails_klass = index_name.constantize
        elastic_klass = "Elastic#{index_name}".constantize
        importer_klass = "Elastic#{index_name}Data".constantize
        elastic_klass.recreate_index
        rails_klass.find_each do |instance|
          importer = importer_klass.new(instance)
          builder = importer.to_builder
          elastic_klass.index(builder.attributes!.symbolize_keys)
        end
      end
    end

    desc 'Recreate an index'
    task :recreate_index, [:index_name] => :environment do |t, args|
      "Elastic#{args.index_name}".constantize.recreate_index
    end
  end
end
