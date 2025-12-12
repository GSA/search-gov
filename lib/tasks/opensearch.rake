namespace :opensearch do
  desc 'Create an index for opensearch engine'
  task create_index: :environment do
    OpenSearch::Indexer.create_index
  end

  desc 'Create ElasticBoostedContent index (supports OPENSEARCH_APP_ENABLED flag)'
  task create_boosted_content_index: :environment do
    puts "Creating ElasticBoostedContent index..."
    ElasticBoostedContent.create_index
    puts "ElasticBoostedContent index created successfully."
  end

  desc 'Create all OpenSearch indexes (OpenSearch::Indexer and ElasticBoostedContent)'
  task create_all_indexes: :environment do
    indexes = [OpenSearch::Indexer, ElasticBoostedContent]
    errors = []

    indexes.each do |klass|
      puts "Creating #{klass} index..."
      klass.create_index
      puts "#{klass} index created successfully."
    rescue StandardError => e
      error_msg = "Failed to create #{klass} error: #{e.message}"
      errors << error_msg
    end

    if errors.empty?
      puts "All OpenSearch indexes created successfully."
    else
      puts "\nCompleted with #{errors.size} error(s):"
      errors.each { |error| puts "  - #{error}" }
    end
  end
end
