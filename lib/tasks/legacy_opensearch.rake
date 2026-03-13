namespace :legacy_opensearch do
  desc 'Create an index for legacy opensearch engine'
  task create_index: :environment do
    LegacyOpenSearch::Indexer.create_index
  end
end
