class SearchgovDomainPreparerJob < ActiveJob::Base
  queue_as :searchgov

  def perform(searchgov_domain:)
    searchgov_domain.check_status
    SitemapIndexerJob.perform_later(searchgov_domain: searchgov_domain)
  end
end
