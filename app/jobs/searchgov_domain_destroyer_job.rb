class SearchgovDomainDestroyerJob < ApplicationJob
  queue_as :searchgov

  def perform(searchgov_domain)
    ActiveRecord::Base.transaction do
      searchgov_domain.searchgov_urls.find_each(batch_size: 100) do |url|
        url.destroy!
      rescue StandardError => e
        Rails.logger.error "Failed to destroy URL #{url.id}: #{e.message}"
      end
      searchgov_domain.destroy!
    end
  rescue StandardError => e
    Rails.logger.error "Failed to destroy SearchgovDomain #{searchgov_domain.id}: #{e.message}"
    raise e
  end
end
