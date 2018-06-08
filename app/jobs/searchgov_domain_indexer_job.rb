class SearchgovDomainIndexerJob < ActiveJob::Base
  queue_as :searchgov

  def perform(searchgov_domain:, delay:)
    searchgov_domain.searchgov_urls.fetch_required.first&.fetch

    if searchgov_domain.searchgov_urls.fetch_required.any?
      SearchgovDomainIndexerJob.set(wait: delay.seconds).
        perform_later(searchgov_domain: searchgov_domain, delay: delay)
    end
  end
end
