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

  desc 'Delete all deprecated custom index data from the database (keeps Best Bets Text)'
  task delete_deprecated_custom_indices: :environment do
    puts 'Deleting deprecated custom index data...'

    # FeaturedCollection (Best Bets Graphics) - dependent destroy handles keywords/links
    count = FeaturedCollection.count
    FeaturedCollection.destroy_all
    puts "Deleted #{count} FeaturedCollection records"

    # FederalRegisterDocument - delete join table first, then documents
    count = FederalRegisterDocument.count
    ActiveRecord::Base.connection.execute('DELETE FROM federal_register_agencies_federal_register_documents')
    FederalRegisterDocument.delete_all
    puts "Deleted #{count} FederalRegisterDocument records"

    # NewsItem
    count = NewsItem.count
    NewsItem.delete_all
    puts "Deleted #{count} NewsItem records"

    # IndexedDocument
    count = IndexedDocument.count
    IndexedDocument.delete_all
    puts "Deleted #{count} IndexedDocument records"

    # SaytSuggestion
    count = SaytSuggestion.count
    SaytSuggestion.delete_all
    puts "Deleted #{count} SaytSuggestion records"

    puts 'Done! Best Bets Text (BoostedContent) data was preserved.'
  end
end
