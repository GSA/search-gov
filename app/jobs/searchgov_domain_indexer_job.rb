class SearchgovDomainIndexerJob < ActiveJob::Base
  queue_as :searchgov

  def perform(searchgov_domain, delay)
    searchgov_domain.searchgov_urls.unfetched.first&.fetch

    if searchgov_domain.searchgov_urls.unfetched.any?
      SearchgovDomainIndexerJob.set(wait: delay.seconds).perform_later(searchgov_domain, delay)
    end
  end
end
