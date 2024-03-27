class SearchgovDomainDestroyerJob < ApplicationJob
  queue_as :searchgov

  def perform(searchgov_domain)
    Resque::Job.destroy('searchgov',
                        'SearchgovDomainIndexerJob',
                        searchgov_domain_id: searchgov_domain.id,
                        delay: searchgov_domain.delay)
    searchgov_domain.searchgov_urls.find_each(&:destroy!)
    searchgov_domain.destroy!
  end
end
