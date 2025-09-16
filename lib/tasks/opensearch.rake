namespace :opensearch do
  desc 'Create an index for opensearch engine'
  task create_index: :environment do
    OpenSearchIndexer.create_index
  end
end
