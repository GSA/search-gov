namespace :opensearch do
  desc 'Create an index for opensearch engine'
  task create_index: :environment do
    OpenSearch::Indexer.create_index
  end
end
