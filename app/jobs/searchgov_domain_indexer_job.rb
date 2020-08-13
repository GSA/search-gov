# frozen_string_literal: true

class SearchgovDomainIndexerJob < ApplicationJob
  queue_as :searchgov

  def perform(searchgov_domain:, delay:)
    searchgov_domain.searchgov_urls.fetch_required.first&.fetch

    if searchgov_domain.searchgov_urls.fetch_required.any?
      SearchgovDomainIndexerJob.set(wait: delay.seconds).
        perform_later(searchgov_domain: searchgov_domain, delay: delay)
    else
      searchgov_domain.done_indexing!
    end
  end
end
