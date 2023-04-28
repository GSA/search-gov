# frozen_string_literal: true

class SearchgovDomainIndexerJob < ApplicationJob
  queue_as :searchgov
  # Prevent multiple jobs from being enqueued simultaneously with the same options. This
  # ensures we respect each website's crawl-delay by fetching URLs one at a time
  # with a delay between them. After a reasonable period of time (lock_ttl), assume
  # something has gone wrong, and unlock the job.
  unique :until_executing, lock_ttl: 30.minutes

  def perform(searchgov_domain:, delay:)
    searchgov_domain.searchgov_urls.fetch_required.first&.fetch

    if searchgov_domain.searchgov_urls.fetch_required.any?
      SearchgovDomainIndexerJob.set(wait: delay.seconds).
        perform_later(searchgov_domain: searchgov_domain, delay: delay)
    else
      Rails.logger.info("Done indexing #{searchgov_domain.domain}")
      searchgov_domain.done_indexing!
    end
  end
end
