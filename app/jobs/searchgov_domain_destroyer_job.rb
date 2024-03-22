class SearchgovDomainDestroyerJob < ApplicationJob
  queue_as :searchgov

  def perform(searchgov_domain)
    searchgov_domain.searchgov_urls.find_each(&:destroy!)
    searchgov_domain.destroy!
    Resque::Job.destroy('searchgov',
                        'SearchgovDomainIndexerJob',
                        searchgov_domain_id: searchgov_domain.id,
                        delay: searchgov_domain.delay)
  end
end
