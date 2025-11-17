namespace :opensearch do
  desc 'Create an index for opensearch engine'
  task create_index: :environment do
    OpenSearch::Indexer.create_index
  end

  desc 'Create ElasticBoostedContent index (supports OPENSEARCH_ENABLED flag)'
  task create_boosted_content_index: :environment do
    puts "Creating ElasticBoostedContent index..."
    ElasticBoostedContent.create_index
    puts "ElasticBoostedContent index created successfully."
  end

  desc 'Create all OpenSearch indexes (OpenSearch::Indexer and ElasticBoostedContent)'
  task create_all_indexes: :environment do
    puts "Creating OpenSearch::Indexer index..."
    OpenSearch::Indexer.create_index
    puts "OpenSearch::Indexer index created successfully."

    puts "Creating ElasticBoostedContent index..."
    ElasticBoostedContent.create_index
    puts "ElasticBoostedContent index created successfully."

    puts "All OpenSearch indexes created successfully."
  end
end
