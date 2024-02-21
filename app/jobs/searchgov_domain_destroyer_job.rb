class SearchgovDomainDestroyerJob < ApplicationJob
  queue_as :searchgov

  def perform(searchgov_domain)
    ActiveRecord::Base.transaction do
      destroy_searchgov_urls(searchgov_domain)
      destroy_searchgov_domain(searchgov_domain)
    end
  rescue StandardError => e
    log_failure('SearchgovDomain', searchgov_domain.id, e.message)
    raise e
  end

  private

  def destroy_searchgov_urls(searchgov_domain)
    searchgov_domain.searchgov_urls.find_each(batch_size: 100) do |url|
      destroy_with_rescue(url)
    end
  end

  def destroy_with_rescue(record)
    record.destroy!
  rescue StandardError => e
    log_failure('URL', record.id, e.message)
  end

  def destroy_searchgov_domain(searchgov_domain)
    searchgov_domain.destroy!
  rescue StandardError => e
    log_failure('SearchgovDomain', searchgov_domain.id, e.message)
    raise e
  end

  def log_failure(type, id, message)
    Rails.logger.error "Failed to destroy #{type} #{id}: #{message}"
  end
end
