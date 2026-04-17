namespace :usasearch do
  namespace :elastic_news_item do
    desc 'Drop the ElasticNewsItem index from all ES clusters'
    task drop_index: :environment do
      index_pattern = [Es::INDEX_PREFIX, 'elastic_news_items', '*'].join('-')
      Es.client_writers.each do |client|
        if client.indices.exists?(index: index_pattern)
          client.indices.delete(index: index_pattern)
          Rails.logger.info "Deleted ElasticNewsItem index matching #{index_pattern}"
        else
          Rails.logger.info "No ElasticNewsItem index found matching #{index_pattern}"
        end
      end
    end
  end
end
